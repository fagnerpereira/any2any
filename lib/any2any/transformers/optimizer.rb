# frozen_string_literal: true

module Any2Any
  module Transformers
    # Optimizes IR by combining nodes and removing unnecessary structures
    class Optimizer < IR::Visitor
      def transform(node)
        visit(node)
        node
      end

      protected

      def visit_template(node)
        # Optimization: nothing special for template
        node.children.each { |child| visit(child) }
      end

      def visit_element(node)
        node.children.each { |child| visit(child) }
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
    end
  end
end
