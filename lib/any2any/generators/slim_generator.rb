# frozen_string_literal: true

module Any2Any
  module Generators
    # IR to Slim generator
    class SlimGenerator < BaseGenerator
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
          output << "\n" unless output.end_with?("\n")
        end
        output.rstrip
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
          # Unknown node type
          ""
        end
      end

      def generate_element(element)
        output = String.new
        output << current_indent
        output << element.tag_name

        # Generate attributes using HTML-style syntax: class="value"
        if element.attributes.any?
          attributes_str = element.attributes.map do |key, value|
            # Escape both HTML chars and Slim interpolation sequences
            "#{key}=\"#{escape_attribute(escape_slim_text(value.to_s))}\""
          end.join(" ")
          output << " #{attributes_str}"
        end

        # Self-closing tags
        if element.self_closing
          return output
        end

        # Handle inline text content
        # Only if single child, is StaticContent, AND has no newlines (multiline breaks inline structure)
        child = element.children.first
        if element.children.length == 1 && child.is_a?(IR::StaticContent) && !child.text.include?("\n")
          output << " #{escape_slim_text(child.text.strip)}"
          return output
        end

        # Generate children
        if element.children.any?
          output << "\n"
          indent do
            element.children.each do |child|
              output << generate_node(child)
              output << "\n" unless output.end_with?("\n")
            end
          end
        end

        output.rstrip
      end

      def generate_expression(expr)
        output = String.new
        output << current_indent
        output << "= #{expr.code}"
        output
      end

      def generate_block(block)
        output = String.new
        output << current_indent
        output << "- #{block.code}"

        if block.children.any?
          output << "\n"
          indent do
            block.children.each do |child|
              output << generate_node(child)
              output << "\n" unless output.end_with?("\n")
            end
          end
        end

        output.rstrip
      end

      def generate_conditional(conditional)
        output = String.new
        output << current_indent
        output << "- if #{conditional.condition}\n"

        indent do
          conditional.true_branch.each do |child|
            output << generate_node(child)
            output << "\n" unless output.end_with?("\n")
          end
        end

        if conditional.false_branch.any?
          output << current_indent << "- else\n"
          indent do
            conditional.false_branch.each do |child|
              output << generate_node(child)
              output << "\n" unless output.end_with?("\n")
            end
          end
        end

        output.rstrip
      end

      def generate_loop(loop_node)
        output = String.new
        output << current_indent
        output << "- #{loop_node.collection}.each do |#{loop_node.variable}|\n"

        indent do
          loop_node.body.each do |child|
            output << generate_node(child)
            output << "\n" unless output.end_with?("\n")
          end
        end

        output.rstrip
      end

      def generate_static_content(content)
        # Skip whitespace-only content
        return "" if content.text.strip.empty?

        output = String.new

        # Handle multiline text safely
        lines = content.text.lines
        lines.each do |line|
          next if line.strip.empty?

          output << current_indent
          output << "| #{escape_slim_text(line.rstrip)}"
          output << "\n"
        end

        output.rstrip
      end

      def generate_comment(comment)
        output = String.new
        output << current_indent

        output << if comment.html_visible
          "/ #{comment.text}"
        else
          "- # #{comment.text}"
        end

        output
      end

      # Escape Slim interpolation sequences
      def escape_slim_text(text)
        return text unless text.is_a?(String)
        # Replace `#{` with `\#{` to prevent interpolation
        text.gsub('#{', '\#{')
      end
    end
  end
end
