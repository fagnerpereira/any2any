# frozen_string_literal: true

module Any2any
  # Main converter class
  class Converter
    def initialize(options = {})
      @options = default_options.merge(options)
    end

    def convert(source, from:, to:)
      # 1. Parse source to IR
      parser = parser_for(from)
      ir = parser.parse(source)

      # 2. Transformations
      ir = transform(ir) if @options[:optimize]

      # 3. Validation
      validate(ir) if @options[:validate]

      # 4. Generate target format
      generator = generator_for(to)
      output = generator.generate(ir)

      # Return output with warnings
      {
        output: output,
        warnings: generator.warnings,
        parser_warnings: parser.warnings
      }
    rescue => e
      raise e if e.is_a?(Error)
      raise Error, "Conversion failed: #{e.message}"
    end

    private

    def default_options
      {
        optimize: false,
        validate: false
      }
    end

    def parser_for(format)
      case format.to_sym
      when :erb
        Parsers::ErbParser.new(@options)
      when :haml
        Parsers::HamlParser.new(@options)
      when :slim
        Parsers::SlimParser.new(@options)
      else
        raise UnsupportedFormat, "Format #{format} not supported"
      end
    end

    def generator_for(format)
      case format.to_sym
      when :erb
        Generators::ErbGenerator.new(@options)
      when :haml
        Generators::HamlGenerator.new(@options)
      when :slim
        Generators::SlimGenerator.new(@options)
      else
        raise UnsupportedFormat, "Format #{format} not supported"
      end
    end

    def transform(ir)
      ir = Transformers::Normalizer.new.transform(ir)
      ir = Transformers::Optimizer.new.transform(ir) if @options[:optimize]
      ir
    end

    def validate(ir)
      Transformers::Validator.new.validate!(ir)
    end
  end
end
