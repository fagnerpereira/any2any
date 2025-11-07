# frozen_string_literal: true

module Any2Any
  module Parsers
    # Base parser class
    class BaseParser
      def initialize(options = {})
        @options = options
        @warnings = WarningCollector.new
      end

      def parse(source)
        raise NotImplementedError, "#{self.class} must implement #parse"
      end

      def warnings
        @warnings
      end

      protected

      def add_warning(message, line: nil, column: nil, severity: :warning, suggestion: nil)
        warning = ConversionWarning.new(
          line: line,
          column: column,
          message: message,
          severity: severity,
          suggestion: suggestion
        )
        @warnings.add(warning)
      end

      def self_closing_tags
        @self_closing_tags ||= Set.new(%w[br hr img input meta link area base col embed source track wbr])
      end

      def void_elements
        self_closing_tags
      end
    end
  end
end
