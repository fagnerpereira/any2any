# frozen_string_literal: true

require 'slim'
require 'temple'

module Any2any
  module Parsers
    # Slim to IR parser using Temple
    class SlimParser < BaseParser
      def parse(source)
        begin
          parser = Slim::Parser.new
          sexp = parser.call(source)
          transform_sexp_to_ir(sexp)
        rescue => e
          raise ParseError, "Failed to parse Slim: #{e.message}"
        end
      end

      private

      def transform_sexp_to_ir(sexp)
        return IR::Template.new(children: []) if sexp.nil?

        case sexp[0]
        when :multi
          # Multiple children - flatten and process
          children = sexp[1..-1].compact.map { |child| transform_sexp_to_ir(child) }.compact
          IR::Template.new(children: children)
        when :html
          # HTML element
          transform_html_tag(sexp)
        when :slim
          # Slim-specific tags (text, interpolate, etc.)
          transform_slim_sexp(sexp)
        when :tag
          # Alternative tag format
          transform_tag_sexp(sexp)
        when :text, :static
          # Static text content
          IR::StaticContent.new(text: sexp[1].to_s)
        when :output, :dynamic, :code_plain
          # Dynamic output
          IR::Expression.new(code: sexp[1].to_s, escaped: sexp[0] != :output_noescape)
        when :code, :silence
          # Code block (no output)
          IR::Block.new(code: sexp[1].to_s)
        when :comment
          # Comments
          IR::Comment.new(text: sexp[1].to_s, html_visible: sexp[0] == :comment)
        when :newline, :slim_comment
          # Ignore newlines and slim comments
          nil
        when :if, :unless, :case
          # Control flow
          transform_control_flow(sexp)
        else
          # Unknown - log warning and skip
          add_warning("Unknown Slim sexp type: #{sexp[0]}")
          nil
        end
      end

      def transform_slim_sexp(sexp)
        # [:slim, :text, :inline, [:multi, [:slim, :interpolate, "Hello"]]]
        # or [:slim, :interpolate, "text"]
        case sexp[1]
        when :text
          # Text with possible interpolation
          content = extract_slim_text(sexp[3..-1])
          IR::StaticContent.new(text: content)
        when :interpolate
          # Direct interpolation
          content = sexp[2].to_s
          IR::StaticContent.new(text: content)
        else
          nil
        end
      end

      def extract_slim_text(sexp_parts)
        return "" unless sexp_parts

        sexp_parts.compact.flat_map do |part|
          if part.is_a?(Array)
            case part[0]
            when :multi
              extract_slim_text(part[1..-1])
            when :slim
              if part[1] == :interpolate
                # This is "Hello" from [:slim, :interpolate, "Hello"]
                [part[2].to_s]
              else
                extract_slim_text(part[1..-1])
              end
            else
              [extract_slim_text([part])]
            end
          else
            [part.to_s]
          end
        end.join
      end

      def transform_html_tag(sexp)
        # sexp = [:html, :tag, "div", [:html, :attrs], [:multi, ...children...], ...]
        # or [:html, :tag, "div", [:html, :attrs], ...]

        tag_name = sexp[2].to_s
        attributes = {}
        children = []

        # Process remaining elements
        (sexp[3..-1] || []).each do |part|
          next unless part

          if part.is_a?(Array)
            case part[0]
            when :html
              if part[1] == :attrs
                # Parse attributes
                attributes = parse_attrs_sexp(part[2..-1])
              else
                # Nested HTML tag - this shouldn't happen directly, HTML tags are in :multi
                child_ir = transform_sexp_to_ir(part)
                children << child_ir if child_ir
              end
            when :multi
              # Multiple children
              (part[1..-1] || []).each do |child|
                next unless child.is_a?(Array)  # Skip non-array items like newlines

                child_ir = transform_sexp_to_ir(child)
                children << child_ir if child_ir
              end
            else
              # Other child node types
              child_ir = transform_sexp_to_ir(part)
              children << child_ir if child_ir
            end
          end
        end

        self_closing = void_elements.include?(tag_name)
        IR::Element.new(
          tag_name: tag_name,
          attributes: attributes,
          children: children,
          self_closing: self_closing
        )
      end

      def transform_tag_sexp(sexp)
        # :tag format from Slim
        # sexp[0] = :tag
        # sexp[1] = tag_name (string or symbol)
        # sexp[2..-1] = attributes and children

        tag_name = sexp[1].to_s
        attributes = {}
        children = []

        (sexp[2] || []).each do |part|
          next unless part

          if part.is_a?(Array)
            case part[0]
            when :attrs
              attributes = parse_attrs_sexp(part[1..-1])
            when :multi, :static, :text, :output, :code, :html, :tag
              child_ir = transform_sexp_to_ir(part)
              children << child_ir if child_ir
            end
          end
        end

        self_closing = void_elements.include?(tag_name)
        IR::Element.new(
          tag_name: tag_name,
          attributes: attributes,
          children: children,
          self_closing: self_closing
        )
      end

      def parse_attrs_sexp(attrs_array)
        attributes = {}

        return attributes unless attrs_array

        attrs_array.compact.each_slice(2) do |key, value|
          next unless key

          attr_key = key.to_s
          attr_value = extract_attr_value(value)
          attributes[attr_key] = attr_value if attr_key && attr_value
        end

        attributes
      end

      def extract_attr_value(value)
        case value
        when String, Symbol
          value.to_s
        when Array
          case value[0]
          when :static, :text
            value[1].to_s
          when :dynamic, :output
            value[1].to_s
          else
            value.inspect
          end
        else
          value.to_s
        end
      end

      def transform_control_flow(sexp)
        # :if, :unless, :case blocks
        condition = sexp[1].to_s
        true_children = []
        false_children = []

        (sexp[2] || []).each do |child|
          next unless child
          ir = transform_sexp_to_ir(child)
          true_children << ir if ir
        end

        (sexp[3] || []).each do |child|
          next unless child
          ir = transform_sexp_to_ir(child)
          false_children << ir if ir
        end

        IR::Conditional.new(
          condition: condition,
          true_branch: true_children,
          false_branch: false_children
        )
      end
    end
  end
end
