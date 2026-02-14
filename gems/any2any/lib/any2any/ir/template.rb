# frozen_string_literal: true

module Any2Any
  module IR
    # Root template node
    class Template < Node
      attr_reader :children

      def initialize(children: [], **opts)
        super(**opts)
        @children = children
      end
    end
  end
end
