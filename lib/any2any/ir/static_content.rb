# frozen_string_literal: true

module TemplateConverter
  module IR
    # Static text content
    class StaticContent < Node
      attr_reader :text

      def initialize(text:, **opts)
        super(**opts)
        @text = text
      end
    end
  end
end
