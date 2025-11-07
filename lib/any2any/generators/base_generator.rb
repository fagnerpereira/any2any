# frozen_string_literal: true

require 'set'

module Any2Any
  module Generators
    # Base generator class
    class BaseGenerator
      attr_reader :warnings

      def initialize(options = {})
        @options = options
        @warnings = WarningCollector.new
        @indent_level = 0
      end

      def generate(ir_node)
        raise NotImplementedError, "#{self.class} must implement #generate"
      end

      protected

      def indent(amount = 1)
        @indent_level += amount
        yield
        @indent_level -= amount
      end

      def current_indent
        '  ' * @indent_level
      end

      def add_warning(message, severity: :warning, suggestion: nil)
        warning = ConversionWarning.new(
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

      # HTML attribute escaping
      def escape_attribute(value)
        return value unless value.is_a?(String)
        value.gsub('&', '&amp;').gsub('"', '&quot;').gsub('<', '&lt;').gsub('>', '&gt;')
      end

      # HTML content escaping
      def escape_html(content)
        return content unless content.is_a?(String)
        content
          .gsub('&', '&amp;')
          .gsub('<', '&lt;')
          .gsub('>', '&gt;')
          .gsub('"', '&quot;')
          .gsub("'", '&#39;')
      end
    end
  end
end
