# frozen_string_literal: true

require 'herb'

module Any2Any
  module Parsers
    # ERB to IR parser using Herb gem
    class ErbParser < BaseParser
      def parse(source)
        begin
          result = Herb.parse(source)
          raise ParseError, "Herb parse failed" if result.errors.any?

          transform_herb_ast_to_ir(result.value)
        rescue ParseError => e
          raise e
        rescue => e
          raise ParseError, "Failed to parse ERB: #{e.message}"
        end
      end

      private

      def transform_herb_ast_to_ir(node)
        case node
        when Herb::AST::DocumentNode
          # Root document
          children = node.children.map { |child| transform_herb_ast_to_ir(child) }.compact
          IR::Template.new(children: children)
        when Herb::AST::HTMLElementNode
          # HTML element like <div>, <p>, etc
          # tag_name is a Token, access via .value
          tag_name_str = node.tag_name.respond_to?(:value) ? node.tag_name.value : node.tag_name.to_s
          attributes = extract_attributes(node)
          children = (node.body || []).map { |child| transform_herb_ast_to_ir(child) }.compact

          self_closing = void_elements.include?(tag_name_str)

          IR::Element.new(
            tag_name: tag_name_str,
            attributes: attributes,
            children: children,
            self_closing: self_closing
          )
        when Herb::AST::HTMLOpenTagNode
          # Opening tag only - shouldn't occur at this level
          nil
        when Herb::AST::HTMLCloseTagNode
          # Closing tag only - shouldn't occur at this level
          nil
        when Herb::AST::ERBContentNode
          # ERB expression or statement
          content_val = node.content.respond_to?(:value) ? node.content.value : node.content.to_s
          code = content_val.to_s.strip
          tag_opening_val = node.tag_opening.respond_to?(:value) ? node.tag_opening.value : node.tag_opening.to_s
          tag_opening = tag_opening_val.to_s

          case tag_opening
          when '<%='
            # Output with escape
            IR::Expression.new(code: code, escaped: true)
          when '<%=='
            # Output without escape
            IR::Expression.new(code: code, escaped: false)
          when '<%#'
            # Comment
            IR::Comment.new(text: code, html_visible: false)
          else
            # Regular code block
            IR::Block.new(code: code)
          end
        when Herb::AST::HTMLTextNode
          # Plain text content
          content_val = node.content.respond_to?(:value) ? node.content.value : node.content.to_s
          text = content_val.to_s
          IR::StaticContent.new(text: text) unless text.empty?
        else
          # Unknown node type
          add_warning("Unknown Herb node type: #{node.class.name}")
          nil
        end
      end

      def extract_attributes(element_node)
        attributes = {}

        # Herb provides attributes through the open_tag.children
        return attributes unless element_node.open_tag

        open_tag = element_node.open_tag
        return attributes unless open_tag.respond_to?(:children) && open_tag.children

        open_tag.children.each do |child|
          # child is an Herb::AST::HTMLAttributeNode
          next unless child.is_a?(Herb::AST::HTMLAttributeNode)
          
          key = extract_attribute_name(child.name)
          value = extract_attribute_value(child.value)
          attributes[key] = value if key && value
        end

        attributes
      end

      def extract_attribute_name(name_node)
        # name_node is an HTMLAttributeNameNode with children
        return nil unless name_node && name_node.respond_to?(:children)
        
        # Get the first LiteralNode child
        literal = name_node.children.first
        return nil unless literal && literal.respond_to?(:content)
        
        literal.content.to_s
      end

      def extract_attribute_value(value_node)
        # value_node is an HTMLAttributeValueNode with children
        return '' unless value_node && value_node.respond_to?(:children)
        
        # Concatenate all literal content from children
        value_node.children.map do |child|
          if child.respond_to?(:content)
            child.content.to_s
          else
            child.to_s
          end
        end.join
      end
    end
  end
end
