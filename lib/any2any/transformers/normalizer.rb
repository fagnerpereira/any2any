# frozen_string_literal: true

module Any2any
  module Transformers
    # Normalizes IR for consistent representation
    class Normalizer < IR::Visitor
      def transform(node)
        visit(node)
        node
      end

      protected

      def visit_template(node)
        # Normalize children by filtering and cleaning
        normalized_children = []

        node.children.each do |child|
          case child
          when IR::StaticContent
            # Combine consecutive static content
            if normalized_children.last.is_a?(IR::StaticContent)
              last = normalized_children.last
              last.instance_variable_set(:@text, "#{last.text}#{child.text}")
            else
              normalized_children << child
            end
          else
            visit(child)
            normalized_children << child
          end
        end

        node.instance_variable_set(:@children, normalized_children)
      end

      def visit_element(node)
        # Recursively normalize children
        normalized_children = []

        node.children.each do |child|
          case child
          when IR::StaticContent
            # Combine consecutive static content
            if normalized_children.last.is_a?(IR::StaticContent)
              last = normalized_children.last
              last.instance_variable_set(:@text, "#{last.text}#{child.text}")
            else
              normalized_children << child
            end
          else
            visit(child)
            normalized_children << child
          end
        end

        node.instance_variable_set(:@children, normalized_children)
      end

      def visit_block(node)
        normalized_children = []

        node.children.each do |child|
          case child
          when IR::StaticContent
            if normalized_children.last.is_a?(IR::StaticContent)
              last = normalized_children.last
              last.instance_variable_set(:@text, "#{last.text}#{child.text}")
            else
              normalized_children << child
            end
          else
            visit(child)
            normalized_children << child
          end
        end

        node.instance_variable_set(:@children, normalized_children)
      end

      def visit_conditional(node)
        visit_branch_children(node, :true_branch)
        visit_branch_children(node, :false_branch)
      end

      def visit_loop(node)
        normalized_body = []

        node.body.each do |child|
          case child
          when IR::StaticContent
            if normalized_body.last.is_a?(IR::StaticContent)
              last = normalized_body.last
              last.instance_variable_set(:@text, "#{last.text}#{child.text}")
            else
              normalized_body << child
            end
          else
            visit(child)
            normalized_body << child
          end
        end

        node.instance_variable_set(:@body, normalized_body)
      end

      private

      def visit_branch_children(node, branch_method)
        branch = node.send(branch_method)
        normalized = []

        branch.each do |child|
          case child
          when IR::StaticContent
            if normalized.last.is_a?(IR::StaticContent)
              last = normalized.last
              last.instance_variable_set(:@text, "#{last.text}#{child.text}")
            else
              normalized << child
            end
          else
            visit(child)
            normalized << child
          end
        end

        node.instance_variable_set(:"@#{branch_method}", normalized)
      end
    end
  end
end
