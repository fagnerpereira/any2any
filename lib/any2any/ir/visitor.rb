# frozen_string_literal: true

module TemplateConverter
  module IR
    # Visitor pattern for IR traversal
    class Visitor
      def visit(node)
        case node
        when Template
          visit_template(node)
        when Element
          visit_element(node)
        when Expression
          visit_expression(node)
        when Block
          visit_block(node)
        when Conditional
          visit_conditional(node)
        when Loop
          visit_loop(node)
        when StaticContent
          visit_static_content(node)
        when Comment
          visit_comment(node)
        else
          visit_other(node)
        end
      end

      protected

      def visit_template(node)
        node.children.each { |child| visit(child) }
      end

      def visit_element(node)
        node.children.each { |child| visit(child) }
      end

      def visit_expression(node)
        # Leaf node
      end

      def visit_block(node)
        node.children.each { |child| visit(child) }
      end

      def visit_conditional(node)
        node.true_branch.each { |child| visit(child) }
        node.false_branch.each { |child| visit(child) }
      end

      def visit_loop(node)
        node.body.each { |child| visit(child) }
      end

      def visit_static_content(node)
        # Leaf node
      end

      def visit_comment(node)
        # Leaf node
      end

      def visit_other(node)
        # Override in subclasses if needed
      end
    end
  end
end
