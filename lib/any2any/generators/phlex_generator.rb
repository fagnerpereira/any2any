# frozen_string_literal: true

module Any2Any
  module Generators
    # IR to Phlex generator
    class PhlexGenerator < BaseGenerator
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
        output << "# frozen_string_literal: true\n\n"
        output << "class ViewComponent < Phlex::HTML\n"

        # Check if we need an initialize method (if there are instance variables)
        has_ivars = template_has_instance_variables?(template)
        if has_ivars
          output << "  def initialize(**attributes)\n"
          output << "    @attributes = attributes\n"
          output << "  end\n\n"
        end

        output << "  def view_template\n"
        template.children.each do |child|
          output << indent(generate_node(child), 2)
        end
        output << "  end\n"
        output << "end\n"
        output
      end

      def generate_node(node, indentation = 0)
        case node
        when IR::Element
          generate_element(node, indentation)
        when IR::Expression
          generate_expression(node, indentation)
        when IR::Block
          generate_block(node, indentation)
        when IR::Conditional
          generate_conditional(node, indentation)
        when IR::Loop
          generate_loop(node, indentation)
        when IR::StaticContent
          generate_static_content(node, indentation)
        when IR::Comment
          generate_comment(node, indentation)
        else
          ""
        end
      end

      def generate_element(element, indentation = 0)
        output = String.new
        indent_str = "  " * indentation

        # Generate opening tag with attributes
        output << "#{indent_str}#{element.tag_name}"

        if element.attributes.any?
          attrs = element.attributes.map do |key, value|
            "#{key}: \"#{escape_quotes(value)}\""
          end.join(", ")
          output << "(#{attrs})"
        end

        # Self-closing elements
        if element.self_closing
          output << "\n"
          return output
        end

        # Elements with children
        if element.children.any?
          output << " do\n"
          element.children.each do |child|
            output << generate_node(child, indentation + 1)
          end
          output << "#{indent_str}end\n"
        else
          output << "\n"
        end

        output
      end

      def generate_expression(expr, indentation = 0)
        indent_str = "  " * indentation
        # In Phlex, expressions are just Ruby code in blocks
        # We use plain for escaped content, or raw for unescaped
        if expr.escaped
          "#{indent_str}plain #{expr.code}\n"
        else
          "#{indent_str}raw #{expr.code}\n"
        end
      end

      def generate_block(block, indentation = 0)
        indent_str = "  " * indentation
        output = String.new

        # Check if it's a block with children (like if/each)
        if block.children.any?
          output << "#{indent_str}#{block.code} do\n"
          block.children.each do |child|
            output << generate_node(child, indentation + 1)
          end
          output << "#{indent_str}end\n"
        else
          # Single line block
          output << "#{indent_str}#{block.code}\n"
        end

        output
      end

      def generate_conditional(conditional, indentation = 0)
        indent_str = "  " * indentation
        output = String.new

        output << "#{indent_str}if #{conditional.condition}\n"

        conditional.true_branch.each do |child|
          output << generate_node(child, indentation + 1)
        end

        if conditional.false_branch.any?
          output << "#{indent_str}else\n"
          conditional.false_branch.each do |child|
            output << generate_node(child, indentation + 1)
          end
        end

        output << "#{indent_str}end\n"
        output
      end

      def generate_loop(loop_node, indentation = 0)
        indent_str = "  " * indentation
        output = String.new

        output << "#{indent_str}#{loop_node.collection}.each do |#{loop_node.variable}|\n"

        loop_node.body.each do |child|
          output << generate_node(child, indentation + 1)
        end

        output << "#{indent_str}end\n"
        output
      end

      def generate_static_content(content, indentation = 0)
        indent_str = "  " * indentation
        text = content.text.strip
        return "" if text.empty?

        # Check if it's just text that should be inside the parent element
        "#{indent_str}plain \"#{escape_quotes(text)}\"\n"
      end

      def generate_comment(comment, indentation = 0)
        indent_str = "  " * indentation
        if comment.html_visible
          "#{indent_str}comment { \"#{escape_quotes(comment.text)}\" }\n"
        else
          "#{indent_str}# #{comment.text}\n"
        end
      end

      def template_has_instance_variables?(template)
        # Simple heuristic: check if any node contains @variable
        has_ivars = false

        visitor = proc do |node|
          case node
          when IR::Expression
            has_ivars = true if node.code.include?('@')
          when IR::Conditional
            has_ivars = true if node.condition.include?('@')
          when IR::Loop
            has_ivars = true if node.collection.include?('@')
          when IR::Element, IR::Template
            node.children.each(&visitor) if node.respond_to?(:children)
          when IR::Block
            node.children.each(&visitor) if node.children
          end
        end

        template.children.each(&visitor)
        has_ivars
      end

      def indent(text, levels)
        indent_str = "  " * levels
        text.lines.map { |line| line.strip.empty? ? "\n" : "#{indent_str}#{line}" }.join
      end

      def escape_quotes(text)
        text.to_s.gsub('"', '\\"')
      end
    end
  end
end
