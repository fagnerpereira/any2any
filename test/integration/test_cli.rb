# frozen_string_literal: true

require 'test_helper'
require 'tempfile'
require 'fileutils'

class TestCLI < Minitest::Test
  def setup
    @cli = Any2Any::CLI.new
  end

  def test_cli_version_command
    output = capture_io do
      @cli.version
    end
    
    assert output[0].include?('any2any')
    assert output[0].include?(Any2Any::VERSION)
  end

  def test_cli_convert_command
    Tempfile.create(['test', '.html.erb']) do |file|
      file.write('<div class="test">Hello</div>')
      file.flush
      
      output_file = file.path.sub('.erb', '.slim')
      
      begin
        @cli.options = {
          from: 'erb',
          to: 'slim',
          output: output_file,
          backup: false
        }
        
        capture_io do
          @cli.convert(file.path)
        end
        
        assert File.exist?(output_file)
        content = File.read(output_file)
        assert content.include?('div')
        assert content.include?('class="test"')
      ensure
        File.delete(output_file) if File.exist?(output_file)
      end
    end
  end

  def test_cli_dry_run
    Tempfile.create(['test', '.html.erb']) do |file|
      file.write('<div>Test</div>')
      file.flush
      
      @cli.options = {
        from: 'erb',
        to: 'slim',
        dry_run: true
      }
      
      output = capture_io do
        @cli.convert(file.path)
      end
      
      assert output[0].include?('Dry Run')
      assert output[0].include?('div')
    end
  end

  def test_cli_batch_conversion
    Dir.mktmpdir do |dir|
      # Create test files
      File.write("#{dir}/test1.html.erb", '<div>Test1</div>')
      File.write("#{dir}/test2.html.erb", '<p>Test2</p>')
      
      @cli.options = {
        from: 'erb',
        to: 'slim',
        recursive: true,
        pattern: '*',
        dry_run: false,
        backup: false
      }
      
      capture_io do
        @cli.batch(dir)
      end
      
      assert File.exist?("#{dir}/test1.html.slim")
      assert File.exist?("#{dir}/test2.html.slim")
    end
  end

  def test_cli_handles_conversion_error
    Tempfile.create(['test', '.html.erb']) do |file|
      file.write('<<<invalid>>>')
      file.flush
      
      @cli.options = {
        from: 'erb',
        to: 'slim',
        output: file.path.sub('.erb', '.slim')
      }
      
      assert_raises(SystemExit) do
        capture_io do
          @cli.convert(file.path)
        end
      end
    end
  end

  def test_cli_warnings_as_errors
    Tempfile.create(['test', '.html.erb']) do |file|
      file.write('<div>Test</div>')
      file.flush
      
      @cli.options = {
        from: 'erb',
        to: 'slim',
        warnings_as_errors: false
      }
      
      capture_io do
        @cli.convert(file.path)
      end
    end
  end

  def test_cli_batch_with_dry_run
    Dir.mktmpdir do |dir|
      File.write("#{dir}/test.html.erb", '<div>Test</div>')
      
      @cli.options = {
        from: 'erb',
        to: 'slim',
        recursive: true,
        pattern: '*',
        dry_run: true
      }
      
      _stdout, _stderr = capture_io do
        @cli.batch(dir)
      end
      
      assert !File.exist?("#{dir}/test.html.slim")
    end
  end

  def test_cli_batch_nonexistent_directory
    @cli.options = {
      from: 'erb',
      to: 'slim'
    }
    
    assert_raises(SystemExit) do
      capture_io do
        @cli.batch('/nonexistent/directory')
      end
    end
  end

  def test_cli_batch_no_matching_files
    Dir.mktmpdir do |dir|
      @cli.options = {
        from: 'erb',
        to: 'slim',
        recursive: true,
        pattern: '*'
      }
      
      stdout, _stderr = capture_io do
        @cli.batch(dir)
      end
      
      assert stdout.include?('No files')
    end
  end

  def test_cli_with_backup
    Tempfile.create(['test', '.html.erb']) do |file|
      file.write('<div>Test</div>')
      file.flush
      
      output_file = file.path.sub('.erb', '.slim')
      File.write(output_file, 'old content')
      
      begin
        @cli.options = {
          from: 'erb',
          to: 'slim',
          output: output_file,
          backup: true
        }
        
        capture_io do
          @cli.convert(file.path)
        end
        
        backup_file = "#{output_file}.bak"
        assert File.exist?(backup_file)
        assert_equal 'old content', File.read(backup_file)
        File.delete(backup_file)
      ensure
        File.delete(output_file) if File.exist?(output_file)
      end
    end
  end

  private

  def capture_io
    require 'stringio'
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    
    yield
    
    [$stdout.string, $stderr.string]
  ensure
    $stdout = old_stdout
    $stderr = old_stderr
  end
end
