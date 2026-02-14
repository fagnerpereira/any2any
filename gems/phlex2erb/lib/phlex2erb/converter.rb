# frozen_string_literal: true

module Phlex2Erb
  class Converter
    def initialize(options = {})
      @options = default_options.merge(options)
    end

    def convert(source)
      parser = Parsers::PhlexParser.new(@options)
      ir = parser.parse(source)

      ir = transform(ir) if @options[:optimize]
      validate(ir) if @options[:validate]

      generator = Generators::ErbGenerator.new(@options)
      output = generator.generate(ir)

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
