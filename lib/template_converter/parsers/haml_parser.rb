# frozen_string_literal: true

require 'haml'

module TemplateConverter
  module Parsers
    # HAML to IR parser
    class HamlParser < BaseParser
      def parse(source)
        begin
          haml_ast = ::Haml::Parser.new(source).parse
          transform_haml_ast_to_ir(haml_ast)
        rescue => e
          raise ParseError, "Failed to parse HAML: #{e.message}"
        end
      end

      private

      def transform_haml_ast_to_ir(node)
        case node
        when ::Haml::Parser::ParseNode
          case node.type
          when :root
            children = node.children.map { |child| transform_haml_ast_to_ir(child) }
            IR::Template.new(children: children)
          when :element
            transform_haml_element(node)
          when :text
            IR::StaticContent.new(text: node.value[:text])
          when :script
            # Ruby code block
            IR::Block.new(code: node.value[:text])
          when :output
            # Ruby expression output
            escaped = node.value.fetch(:escape_html, true)
            IR::Expression.new(code: node.value[:text], escaped: escaped)
          when :comment
            IR::Comment.new(text: node.value[:text], html_visible: true)
          when :silent_comment
            IR::Comment.new(text: node.value[:text], html_visible: false)
          when :if
            transform_haml_conditional(node)
          when :loop
            transform_haml_loop(node)
          else
            add_warning("Unknown HAML node type: #{node.type}")
            IR::StaticContent.new(text: '')
          end
        when String
          IR::StaticContent.new(text: node)
        else
          IR::StaticContent.new(text: '')
        end
      end

      def transform_haml_element(node)
        tag_name = node.value[:name]
        attributes = parse_haml_attributes(node.value[:attributes])
        self_closing = void_elements.include?(tag_name)

        children = if node.children.any?
                     node.children.map { |child| transform_haml_ast_to_ir(child) }
                   else
                     []
                   end

        IR::Element.new(
          tag_name: tag_name,
          attributes: attributes,
          children: children,
          self_closing: self_closing
        )
      end

      def transform_haml_conditional(node)
        condition = node.value[:text]
        true_branch = node.children.map { |child| transform_haml_ast_to_ir(child) }
        false_branch = []

        IR::Conditional.new(
          condition: condition,
          true_branch: true_branch,
          false_branch: false_branch
        )
      end

      def transform_haml_loop(node)
        # Parse loop syntax: "variable in collection"
        match = node.value[:text].match(/(\w+)\s+in\s+(.+)/)
        if match
          variable = match[1]
          collection = match[2]
        else
          # Fallback
          variable = 'item'
          collection = 'collection'
        end

        body = node.children.map { |child| transform_haml_ast_to_ir(child) }

        IR::Loop.new(
          collection: collection,
          variable: variable,
          body: body
        )
      end

      def parse_haml_attributes(attributes_hash)
        return {} unless attributes_hash

        result = {}
        attributes_hash.each do |key, value|
          result[key.to_s] = value.to_s
        end
        result
      end
    end
  end
end
