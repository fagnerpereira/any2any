# frozen_string_literal: true

require 'thor'
require 'fileutils'
require 'pastel'

module Any2Any
  # CLI interface
  class CLI < Thor
    desc 'version', 'Show version'
    def version
      puts "any2any #{Any2Any::VERSION}"
    end

    desc 'convert INPUT', 'Convert a template file'
    option :from, required: true, desc: 'Source format (erb, haml, slim)'
    option :to, required: true, desc: 'Target format (erb, haml, slim)'
    option :output, aliases: '-o', desc: 'Output file (default: stdout)'
    option :dry_run, aliases: '-n', type: :boolean, desc: 'Show output without writing'
    option :diff, type: :boolean, desc: 'Show diff with original (if output file exists)'
    option :validate, type: :boolean, desc: 'Validate IR before generating'
    option :optimize, type: :boolean, desc: 'Optimize IR'
    option :warnings_as_errors, type: :boolean, desc: 'Treat warnings as errors'
    option :backup, type: :boolean, default: true, desc: 'Backup original file'
    def convert(input_file)
      begin
        # Read input file
        source = File.read(input_file)

        # Convert
        converter = Converter.new(
          validate: options[:validate],
          optimize: options[:optimize]
        )
        result = converter.convert(source, from: options[:from].to_sym, to: options[:to].to_sym)

        output = result[:output]
        warnings = combine_warnings(result)

        # Show warnings
        show_warnings(warnings) if warnings.any?

        # Check for errors
        if options[:warnings_as_errors] && warnings.any?
          puts pastel.red("✗ Conversion failed due to warnings")
          exit 1
        end

        # Determine output file
        if options[:output]
          output_file = options[:output]
        elsif !options[:dry_run]
          output_file = determine_output_filename(input_file, options[:from], options[:to])
        end

        if options[:dry_run]
          puts pastel.blue("=== Dry Run Preview ===")
          puts output
        elsif output_file
          # Backup original if it exists and option is enabled
          if File.exist?(output_file) && options[:backup]
            backup_file = "#{output_file}.bak"
            FileUtils.cp(output_file, backup_file)
            puts pastel.yellow("Backed up original to: #{backup_file}")
          end

          # Write output
          File.write(output_file, output)
          puts pastel.green("✓ Converted to: #{output_file}")

          # Show diff if requested
          if options[:diff] && File.exist?(input_file)
            show_diff(input_file, output_file)
          end
        else
          puts output
        end
      rescue => e
        puts pastel.red("✗ Error: #{e.message}")
        exit 1
      end
    end

    desc 'batch DIRECTORY', 'Convert all templates in a directory'
    option :from, required: true, desc: 'Source format (erb, haml, slim)'
    option :to, required: true, desc: 'Target format (erb, haml, slim)'
    option :recursive, aliases: '-r', type: :boolean, default: true, desc: 'Recurse into subdirectories'
    option :pattern, aliases: '-p', default: '*', desc: 'File pattern to match'
    option :dry_run, aliases: '-n', type: :boolean, desc: 'Show what would be done'
    option :validate, type: :boolean, desc: 'Validate IR before generating'
    option :optimize, type: :boolean, desc: 'Optimize IR'
    option :backup, type: :boolean, default: true, desc: 'Backup original files'

    def batch(directory)
      begin
        unless File.directory?(directory)
          puts pastel.red("✗ Directory not found: #{directory}")
          exit 1
        end

        # Find files
        ext = ".#{options[:from]}"
        pattern = options[:recursive] ? "#{directory}/**/#{options[:pattern]}#{ext}" : "#{directory}/#{options[:pattern]}#{ext}"
        files = Dir.glob(pattern)

        if files.empty?
          puts pastel.yellow("No files matching pattern found")
          return
        end

        # Convert each file
        converted = 0
        failed = 0
        warned = 0

        files.each do |file|
          print "Converting #{file}... "

          begin
            source = File.read(file)
            converter = Converter.new(
              validate: options[:validate],
              optimize: options[:optimize]
            )
            result = converter.convert(source, from: options[:from].to_sym, to: options[:to].to_sym)
            output = result[:output]
            warnings = combine_warnings(result)

            if warnings.any?
              puts pastel.yellow("⚠ with warnings")
              warned += 1
            else
              unless options[:dry_run]
                output_file = determine_output_filename(file, options[:from], options[:to])

                if File.exist?(output_file) && options[:backup]
                  backup_file = "#{output_file}.bak"
                  FileUtils.cp(output_file, backup_file)
                end

                File.write(output_file, output)
              end
              puts pastel.green("✓")
              converted += 1
            end
          rescue => e
            puts pastel.red("✗ #{e.message}")
            failed += 1
          end
        end

        # Summary
        puts "\n" + pastel.blue("=== Batch Summary ===")
        puts pastel.green("✓ #{converted} files converted")
        puts pastel.yellow("⚠ #{warned} files with warnings") if warned > 0
        puts pastel.red("✗ #{failed} files failed") if failed > 0
      rescue => e
        puts pastel.red("✗ Error: #{e.message}")
        exit 1
      end
    end

    private

    def pastel
      @pastel ||= Pastel.new
    end

    def combine_warnings(result)
      warnings = []
      warnings.concat(result[:warnings].all) if result[:warnings]
      warnings.concat(result[:parser_warnings].all) if result[:parser_warnings]
      warnings
    end

    def show_warnings(warnings)
      puts "\n" + pastel.yellow("=== Warnings ===")
      warnings.each { |w| puts w.to_s }
    end

    def show_diff(file1, file2)
      require 'diff/lcs'
      require 'diff/lcs/hunk'

      content1 = File.readlines(file1)
      content2 = File.readlines(file2)

      diffs = Diff::LCS.diff(content1, content2)

      return if diffs.empty?

      puts "\n" + pastel.blue("=== Diff ===")
      hunks = Diff::LCS::Hunk.hunks(content1, diffs)
      hunks.each { |hunk| puts hunk }
    end

    def determine_output_filename(input_file, from_format, to_format)
      # Handle Phlex special case: .phlex files should be .rb
      if to_format.to_s == 'phlex'
        # Convert to .rb extension
        # Remove any template extensions like .html.erb, .html.slim, etc.
        base = input_file.sub(/\.(html\.)?(erb|slim|haml|phlex)$/, '')
        "#{base}.rb"
      elsif from_format.to_s == 'phlex'
        # Converting from Phlex (.rb) to another format
        # Add appropriate template extension
        base = input_file.sub(/\.rb$/, '')
        "#{base}.html.#{to_format}"
      else
        # Standard conversion between template formats
        ext_from = File.extname(input_file)
        ext_to = ".#{to_format}"
        input_file.sub(/#{Regexp.escape(ext_from)}$/, ext_to)
      end
    end
  end
end
