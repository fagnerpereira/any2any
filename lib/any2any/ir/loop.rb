# frozen_string_literal: true

module Any2any
  module IR
    # Loop (each, while, for)
    class Loop < Node
      attr_reader :collection, :variable, :body

      def initialize(collection:, variable:, body: [], **opts)
        super(**opts)
        @collection = collection
        @variable = variable
        @body = body
      end
    end
  end
end
