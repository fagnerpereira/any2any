# frozen_string_literal: true

module Any2any
  module IR
    # HTML element node
    class Element < Node
      attr_reader :tag_name, :attributes, :children, :self_closing

      def initialize(tag_name:, attributes: {}, children: [], self_closing: false, **opts)
        super(**opts)
        @tag_name = tag_name
        @attributes = attributes
        @children = children
        @self_closing = self_closing
      end
    end
  end
end
