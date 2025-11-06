# frozen_string_literal: true

module TemplateConverter
  module Parsers
    # HAML to IR parser - simplified for MVP
    class HamlParser < BaseParser
      def parse(source)
        begin
          lines = source.split("\n")
          children, _remaining = parse_lines(lines, 0, -1)
          IR::Template.new(children: children)
        rescue => e
          raise ParseError, "Failed to parse HAML: #{e.message}"
        end
      end

      private

      def parse_lines(lines, start_idx, parent_indent)
        children = []
        i = start_idx

        while i < lines.length
          line = lines[i]
          indent_level = count_indent(line)

          # Stop if we're back to parent level or less
          break if parent_indent >= 0 && indent_level <= parent_indent

          # Skip empty lines
          if line.strip.empty?
            i += 1
            next
          end

          # Parse the line
          node = parse_line(line.strip)

          if node
            # Check for children
            if i + 1 < lines.length && count_indent(lines[i + 1]) > indent_level
              child_children, i = parse_lines(lines, i + 1, indent_level)

              # Add children to element if applicable
              if node.is_a?(IR::Element)
                node.instance_variable_set(:@children, child_children)
              elsif node.is_a?(IR::Block) || node.is_a?(IR::Conditional) || node.is_a?(IR::Loop)
                # These can have children too
                case node
                when IR::Block
                  node.instance_variable_set(:@children, child_children)
                when IR::Conditional
                  node.instance_variable_set(:@true_branch, child_children)
                when IR::Loop
                  node.instance_variable_set(:@body, child_children)
                end
              end
            else
              i += 1
            end

            children << node
          else
            i += 1
          end
        end

        [children, i]
      end

      def count_indent(line)
        line.match(/^(\s*)/)[1].length / 2  # HAML uses 2-space indents
      end

      def parse_line(line)
        # Handle silent comment first
        if line.start_with?('-#')
          text = line[2..-1].strip
          return IR::Comment.new(text: text, html_visible: false)
        end

        case line[0]
        when '%'
          # HTML element: %div.class#id{ attr: val }
          parse_haml_element(line)
        when '-'
          # Ruby code: - code
          code = line[1..-1].strip
          if code.start_with?('if ') || code.start_with?('unless ')
            IR::Conditional.new(condition: code.sub(/^(if|unless)\s+/, ''), true_branch: [], false_branch: [])
          elsif code.start_with?('each ')
            # each syntax: - item.collection.each do |item|
            match = code.match(/(\w+)\.(\w+)\.each\s+do\s*\|\s*(\w+)\s*\|/)
            if match
              collection = "#{match[1]}.#{match[2]}"
              variable = match[3]
            else
              collection = 'collection'
              variable = 'item'
            end
            IR::Loop.new(collection: collection, variable: variable, body: [])
          else
            IR::Block.new(code: code)
          end
        when '='
          # Output expression: = @var
          code = line[1..-1].strip
          escaped = !line.start_with?('==')
          IR::Expression.new(code: code, escaped: escaped)
        when '/'
          # Comment: / comment text
          text = line[1..-1].strip
          IR::Comment.new(text: text, html_visible: true)
        else
          # Plain text
          IR::StaticContent.new(text: line) unless line.empty?
        end
      end

      def parse_haml_element(line)
        # Parse: %tag.class#id{ attr: val } content
        # For MVP, simplified parsing
        match = line.match(/^%([a-z][a-z0-9]*)(.*?)(?:\s+(.*))?$/)
        return nil unless match

        tag_name = match[1]
        class_and_id = match[2]
        content = match[3]

        # Parse classes and IDs
        attributes = {}
        class_and_id.scan(/\.([a-z0-9_-]+)/).each { |m| attributes['class'] = m[0] }
        class_and_id.scan(/#([a-z0-9_-]+)/).each { |m| attributes['id'] = m[0] }

        # Parse inline content
        children = []
        children << IR::StaticContent.new(text: content) if content && !content.empty?

        self_closing = void_elements.include?(tag_name)

        IR::Element.new(
          tag_name: tag_name,
          attributes: attributes,
          children: children,
          self_closing: self_closing
        )
      end
    end
  end
end
