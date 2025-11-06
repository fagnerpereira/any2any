# frozen_string_literal: true

module Any2any
  module Transformers
    # Validates IR structure
    class Validator < IR::Visitor
      def initialize
        super
        @errors = []
      end

      def validate!(node)
        @errors.clear
        visit(node)
        raise ValidationError, "Validation failed: #{@errors.join(', ')}" if @errors.any?
      end

      protected

      def visit_template(node)
        @errors << "Template must have children" if node.children.nil?
        node.children&.each { |child| visit(child) }
      end

      def visit_element(node)
        @errors << "Element must have tag_name" if node.tag_name.nil? || node.tag_name.empty?
        @errors << "Element tag_name must be a string" unless node.tag_name.is_a?(String)
        @errors << "Element attributes must be a hash" unless node.attributes.is_a?(Hash)
        node.children&.each { |child| visit(child) }
      end

      def visit_expression(node)
        @errors << "Expression must have code" if node.code.nil? || node.code.empty?
        @errors << "Expression code must be a string" unless node.code.is_a?(String)
      end

      def visit_block(node)
        @errors << "Block must have code" if node.code.nil? || node.code.empty?
        @errors << "Block code must be a string" unless node.code.is_a?(String)
        node.children&.each { |child| visit(child) }
      end

      def visit_conditional(node)
        @errors << "Conditional must have condition" if node.condition.nil? || node.condition.empty?
        @errors << "Conditional condition must be a string" unless node.condition.is_a?(String)
        node.true_branch&.each { |child| visit(child) }
        node.false_branch&.each { |child| visit(child) }
      end

      def visit_loop(node)
        @errors << "Loop must have collection" if node.collection.nil? || node.collection.empty?
        @errors << "Loop must have variable" if node.variable.nil? || node.variable.empty?
        @errors << "Loop collection must be a string" unless node.collection.is_a?(String)
        @errors << "Loop variable must be a string" unless node.variable.is_a?(String)
        node.body&.each { |child| visit(child) }
      end

      def visit_static_content(node)
        @errors << "StaticContent must have text" if node.text.nil?
        @errors << "StaticContent text must be a string" unless node.text.is_a?(String)
      end

      def visit_comment(node)
        @errors << "Comment must have text" if node.text.nil?
        @errors << "Comment text must be a string" unless node.text.is_a?(String)
      end
    end
  end
end
