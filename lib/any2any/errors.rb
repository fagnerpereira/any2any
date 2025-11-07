# frozen_string_literal: true

module Any2Any
  # Base error class
  class Error < StandardError; end

  # Raised when unsupported format is requested
  class UnsupportedFormat < Error; end

  # Raised when parsing fails
  class ParseError < Error
    attr_reader :line, :column, :message

    def initialize(message, line: nil, column: nil)
      @message = message
      @line = line
      @column = column
      super(format_message)
    end

    private

    def format_message
      return @message if @line.nil?
      "Line #{@line}, Col #{@column}: #{@message}"
    end
  end

  # Raised when validation fails
  class ValidationError < Error; end

  # Conversion warning
  class ConversionWarning
    attr_reader :line, :column, :severity, :message, :suggestion

    SEVERITIES = [:info, :warning, :error].freeze

    def initialize(line: nil, column: nil, message:, severity: :warning, suggestion: nil)
      @line = line
      @column = column
      @severity = severity
      @message = message
      @suggestion = suggestion
    end

    def to_s
      msg = severity == :info ? "[INFO]" : "[#{severity.upcase}]"
      msg += " Line #{@line}" if @line
      msg += ": #{@message}"
      msg += "\n  Suggestion: #{@suggestion}" if @suggestion
      msg
    end
  end

  # Collects warnings during conversion
  class WarningCollector
    def initialize
      @warnings = []
    end

    def add(warning)
      @warnings << warning
    end

    def all
      @warnings
    end

    def errors
      @warnings.select { |w| w.severity == :error }
    end

    def warnings
      @warnings.select { |w| w.severity == :warning }
    end

    def infos
      @warnings.select { |w| w.severity == :info }
    end

    def has_errors?
      errors.any?
    end

    def summary
      "Conversion complete: #{errors.length} errors, #{warnings.length} warnings, #{infos.length} info messages"
    end

    def to_s
      @warnings.map(&:to_s).join("\n")
    end

    def clear
      @warnings.clear
    end
  end
end
