# frozen_string_literal: true

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
        "  " * @indent_level
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
        value.gsub("&", "&amp;").gsub('"', "&quot;").gsub("<", "&lt;").gsub(">", "&gt;")
      end

      # HTML content escaping
      def escape_html(content)
        return content unless content.is_a?(String)
        content
          .gsub("&", "&amp;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
          .gsub('"', "&quot;")
          .gsub("'", "&#39;")
      end

      # Safely generate a Ruby string literal (e.g. for attributes)
      # Escapes quote marks and ensures interpolation sequences are neutralized
      def ruby_string_literal(text)
        return '""' unless text.is_a?(String)

        # Use inspect to get a valid Ruby string literal
        literal = text.inspect

        # inspect does NOT escape interpolation sequences like #{...}
        # because they are valid in Ruby string literals (interpolated at runtime).
        # But we are generating code that will be parsed again by the template engine.
        # So we must escape #{ to \#{ to prevent execution.
        literal.gsub('#{', '\#{')
      end

      # Escape content that might be interpolated by the template engine (HAML/Slim text)
      def escape_to_interpolation(text)
        return text unless text.is_a?(String)

        # Escape backslashes first (to avoid escaping the backslash we add later)
        # Then escape interpolation start sequence
        text.gsub('\\', '\\\\').gsub('#{', '\#{')
      end

      # Escape ERB tags to prevent SSTI
      def escape_erb_tags(text)
        return text unless text.is_a?(String)
        text.gsub('<%', '<%%')
      end
    end
  end
end
