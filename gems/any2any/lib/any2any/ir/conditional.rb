# frozen_string_literal: true

module Any2Any
  module IR
    # Conditional (if/elsif/else)
    class Conditional < Node
      attr_reader :condition, :true_branch, :false_branch

      def initialize(condition:, true_branch: [], false_branch: [], **opts)
        super(**opts)
        @condition = condition
        @true_branch = true_branch
        @false_branch = false_branch
      end
    end
  end
end
