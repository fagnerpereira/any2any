# frozen_string_literal: true

module Phlex2Haml
  module IR
    # Ruby expression with output
    class Expression < Node
      attr_reader :code, :escaped

      def initialize(code:, escaped: true, **opts)
        super(**opts)
        @code = code
        @escaped = escaped
      end
    end
  end
end
