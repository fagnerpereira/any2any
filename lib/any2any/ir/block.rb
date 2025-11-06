# frozen_string_literal: true

module Any2any
  module IR
    # Ruby block without output
    class Block < Node
      attr_reader :code, :children

      def initialize(code:, children: [], **opts)
        super(**opts)
        @code = code
        @children = children
      end
    end
  end
end
