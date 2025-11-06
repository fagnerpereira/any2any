# frozen_string_literal: true

module Any2any
  module IR
    # Comment (HTML or code comment)
    class Comment < Node
      attr_reader :text, :html_visible

      def initialize(text:, html_visible: false, **opts)
        super(**opts)
        @text = text
        @html_visible = html_visible
      end
    end
  end
end
