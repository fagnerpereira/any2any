# frozen_string_literal: true

require "thor"
require "pastel"
require "tty-prompt"

module Erb2Slim
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    desc "convert INPUT_FILE [OUTPUT_FILE]", "Convert ERB to SLIM"
    method_option :optimize, type: :boolean, default: false, desc: "Optimize the output"
    method_option :validate, type: :boolean, default: false, desc: "Validate IR before generation"
    def convert(input_file, output_file = nil)
      pastel = Pastel.new

      unless File.exist?(input_file)
        abort pastel.red("Error: File #{input_file} not found")
      end

      source = File.read(input_file)
      result = Erb2Slim.convert(source, options: options)

      if output_file
        File.write(output_file, result[:output])
        puts pastel.green("Successfully converted #{input_file} to #{output_file}")
      else
        puts result[:output]
      end

      if result[:warnings].any? || result[:parser_warnings].any?
        puts pastel.yellow("\nWarnings:")
        (result[:parser_warnings] + result[:warnings]).each do |warning|
          puts pastel.yellow("- #{warning}")
        end
      end
    rescue StandardError => e
      abort pastel.red("Error: #{e.message}")
    end

    default_task :convert
  end
end
