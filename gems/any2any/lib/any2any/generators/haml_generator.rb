# frozen_string_literal: true

module Any2Any
  module Generators
    # IR to HAML generator
    class HamlGenerator < BaseGenerator
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
          ""
        end
      end

      def generate_element(element)
        output = String.new
        output << current_indent
        output << "%#{element.tag_name}"

        # Generate attributes using HAML hash syntax {key: "value"}
        if element.attributes.any?
          attrs = element.attributes.map do |key, value|
            # Use symbol keys for HAML
            "#{key}: \"#{escape_attribute(value.to_s)}\""
          end.join(", ")
          output << "{#{attrs}}"
        end

        # Self-closing tags
        if element.self_closing
          return output
        end

        # Handle inline text content only if it's single line
        if element.children.length == 1 &&
           element.children.first.is_a?(IR::StaticContent) &&
           !element.children.first.text.include?("\n")

          # HAML handles inline text safely if it's on the same line after the tag
          # e.g. %div %content -> <div>%content</div>
          # But we should trim it
          output << " #{element.children.first.text.strip}"
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

        output << if expr.escaped
          "= #{expr.code}"
        else
          "!= #{expr.code}"
        end

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
        # Skip whitespace-only content if it's just a single line or empty
        # But we need to be careful not to skip significant whitespace if needed
        # For now, stick to original behavior but handle lines
        text = content.text
        return "" if text.strip.empty?

        output = String.new
        lines = text.lines

        lines.each_with_index do |line, index|
          line_content = line.chomp

          if line_content.strip.empty?
             # Preserve empty lines
             output << "\n" unless index == lines.size - 1
             next
          end

          output << current_indent

          # Escape lines starting with HAML special characters
          if line_content.lstrip.match?(/^[%#=\-\/\.!]/)
            output << "\\"
          end

          output << line_content
          output << "\n" unless index == lines.size - 1
        end

        output
      end

      def generate_comment(comment)
        output = String.new
        output << current_indent

        output << if comment.html_visible
          "/ #{comment.text}"
        else
          "-# #{comment.text}"
        end

        output
      end
    end
  end
end
