# frozen_string_literal: true

module Any2Any
  module Generators
    # IR to ERB generator
    class ErbGenerator < BaseGenerator
      def generate(ir_node)
        case ir_node
        when IR::Template
          generate_template(ir_node)
        else
          raise ArgumentError, "Expected IR::Template, got #{ir_node.class}"
        end
      end

      private

      def generate_template(template)
        output = String.new
        template.children.each do |child|
          output << generate_node(child)
        end
        output
      end

      def generate_node(node)
        case node
        when IR::Element
          generate_element(node)
        when IR::Expression
          generate_expression(node)
        when IR::Block
          generate_block(node)
        when IR::Conditional
          generate_conditional(node)
        when IR::Loop
          generate_loop(node)
        when IR::StaticContent
          generate_static_content(node)
        when IR::Comment
          generate_comment(node)
        else
          ""
        end
      end

      def generate_element(element)
        output = String.new
        output << "<#{element.tag_name}"

        # Generate attributes
        if element.attributes.any?
          element.attributes.each do |key, value|
            output << " #{key}=\"#{escape_attribute(value.to_s)}\""
          end
        end

        # Self-closing tags
        if element.self_closing
          output << " />"
          return output
        end

        output << ">"

        # Generate children
        element.children.each do |child|
          output << generate_node(child)
        end

        output << "</#{element.tag_name}>"
        output
      end

      def generate_expression(expr)
        if expr.escaped
          "<%= #{expr.code} %>"
        else
          "<%== #{expr.code} %>"
        end
      end

      def generate_block(block)
        "<% #{block.code} %>"
      end

      def generate_conditional(conditional)
        output = String.new
        output << "<% if #{conditional.condition} %>"

        conditional.true_branch.each do |child|
          output << generate_node(child)
        end

        if conditional.false_branch.any?
          output << "<% else %>"
          conditional.false_branch.each do |child|
            output << generate_node(child)
          end
        end

        output << "<% end %>"
        output
      end

      def generate_loop(loop_node)
        output = String.new
        output << "<% #{loop_node.collection}.each do |#{loop_node.variable}| %>"

        loop_node.body.each do |child|
          output << generate_node(child)
        end

        output << "<% end %>"
        output
      end

      def generate_static_content(content)
        content.text
      end

      def generate_comment(comment)
        if comment.html_visible
          "<!-- #{comment.text} -->"
        else
          "<%# #{comment.text} %>"
        end
      end
    end
  end
end
