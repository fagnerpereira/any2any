# frozen_string_literal: true

require 'erb'

module TemplateConverter
  module Parsers
    # ERB to IR parser
    class ErbParser < BaseParser
      # Simple ERB parser that doesn't require a full AST library
      def parse(source)
        begin
          tokenize_and_parse(source)
        rescue => e
          raise ParseError, "Failed to parse ERB: #{e.message}"
        end
      end

      private

      def tokenize_and_parse(source)
        tokens = tokenize(source)
        parse_tokens(tokens)
      end

      def tokenize(source)
        tokens = []
        pos = 0

        while pos < source.length
          # Look for ERB tags
          erb_start = source.index('<%', pos)

          if erb_start.nil?
            # No more ERB tags, rest is static content
            tokens << [:static, source[pos..-1]] if pos < source.length
            break
          end

          # Add static content before ERB tag
          tokens << [:static, source[pos...erb_start]] if pos < erb_start

          # Find end of ERB tag
          erb_end = source.index('%>', erb_start + 2)
          raise ParseError, "Unclosed ERB tag at position #{erb_start}" if erb_end.nil?

          # Extract ERB content
          erb_content = source[erb_start + 2...erb_end].strip

          # Determine type and store
          if erb_content.start_with?('=')
            # Output tag
            code = erb_content[1..-1].strip
            escaped = !erb_content.start_with?('==')
            tokens << [:output, code, escaped]
          elsif erb_content.start_with?('-')
            # Comment tag
            text = erb_content[1..-1].strip
            tokens << [:comment, text]
          else
            # Code block
            tokens << [:code, erb_content]
          end

          pos = erb_end + 2
        end

        tokens
      end

      def parse_tokens(tokens)
        children = []
        i = 0

        while i < tokens.length
          token = tokens[i]

          case token[0]
          when :static
            children << IR::StaticContent.new(text: token[1]) unless token[1].empty?
          when :output
            children << IR::Expression.new(code: token[1], escaped: token[2])
          when :code
            # Check if it's a control flow statement
            code = token[1]
            if code.match?(/^\s*(if|unless|elsif|when)\b/)
              # This is a conditional - need to parse the full structure
              i, conditional = parse_conditional(tokens, i)
              children << conditional
              next
            elsif code.match?(/^\s*(each|while|for)\b/)
              # This is a loop - need to parse the full structure
              i, loop_node = parse_loop(tokens, i)
              children << loop_node
              next
            else
              # Regular code block
              children << IR::Block.new(code: code)
            end
          when :comment
            children << IR::Comment.new(text: token[1], html_visible: false)
          end

          i += 1
        end

        IR::Template.new(children: children)
      end

      def parse_conditional(tokens, start_idx)
        # Simplified conditional parsing for basic if/else/end
        condition_code = tokens[start_idx][1]
        condition = extract_condition(condition_code)

        true_branch = []
        i = start_idx + 1

        while i < tokens.length
          token = tokens[i]
          break if token[0] == :code && token[1].strip == 'end'

          case token[0]
          when :static
            true_branch << IR::StaticContent.new(text: token[1]) unless token[1].empty?
          when :output
            true_branch << IR::Expression.new(code: token[1], escaped: token[2])
          when :code
            true_branch << IR::Block.new(code: token[1])
          when :comment
            true_branch << IR::Comment.new(text: token[1], html_visible: false)
          end

          i += 1
        end

        # Skip the 'end' token
        i += 1

        [i - 1, IR::Conditional.new(condition: condition, true_branch: true_branch, false_branch: [])]
      end

      def parse_loop(tokens, start_idx)
        loop_code = tokens[start_idx][1]
        loop_match = loop_code.match(/each\s+do\s*\|\s*(\w+)\s*\|\s*(.*)/)

        if loop_match
          variable = loop_match[1]
          collection_part = loop_match[2]
          # Try to extract collection from surrounding context
          collection = collection_part.empty? ? 'collection' : collection_part
        else
          variable = 'item'
          collection = 'collection'
        end

        body = []
        i = start_idx + 1

        while i < tokens.length
          token = tokens[i]
          break if token[0] == :code && token[1].strip == 'end'

          case token[0]
          when :static
            body << IR::StaticContent.new(text: token[1]) unless token[1].empty?
          when :output
            body << IR::Expression.new(code: token[1], escaped: token[2])
          when :code
            body << IR::Block.new(code: token[1])
          when :comment
            body << IR::Comment.new(text: token[1], html_visible: false)
          end

          i += 1
        end

        # Skip the 'end' token
        i += 1

        [i - 1, IR::Loop.new(collection: collection, variable: variable, body: body)]
      end

      def extract_condition(code)
        code.gsub(/^\s*(if|unless|elsif|when)\s+/, '').strip
      end
    end
  end
end
