# frozen_string_literal: true

require 'test_helper'

class TestCliFileExtensions < Minitest::Test
  def setup
    @cli = Any2Any::CLI.new
  end

  def test_determine_output_filename_erb_to_slim
    input = 'app/views/users/index.html.erb'
    output = @cli.send(:determine_output_filename, input, 'erb', 'slim')
    assert_equal 'app/views/users/index.html.slim', output
  end

  def test_determine_output_filename_erb_to_haml
    input = 'app/views/users/index.html.erb'
    output = @cli.send(:determine_output_filename, input, 'erb', 'haml')
    assert_equal 'app/views/users/index.html.haml', output
  end

  def test_determine_output_filename_erb_to_phlex
    input = 'app/views/users/index.html.erb'
    output = @cli.send(:determine_output_filename, input, 'erb', 'phlex')
    assert_equal 'app/views/users/index.rb', output
  end

  def test_determine_output_filename_slim_to_phlex
    input = 'app/views/users/show.html.slim'
    output = @cli.send(:determine_output_filename, input, 'slim', 'phlex')
    assert_equal 'app/views/users/show.rb', output
  end

  def test_determine_output_filename_haml_to_phlex
    input = 'app/views/users/edit.html.haml'
    output = @cli.send(:determine_output_filename, input, 'haml', 'phlex')
    assert_equal 'app/views/users/edit.rb', output
  end

  def test_determine_output_filename_phlex_to_erb
    input = 'app/views/users/index.rb'
    output = @cli.send(:determine_output_filename, input, 'phlex', 'erb')
    assert_equal 'app/views/users/index.html.erb', output
  end

  def test_determine_output_filename_phlex_to_slim
    input = 'app/views/users/show.rb'
    output = @cli.send(:determine_output_filename, input, 'phlex', 'slim')
    assert_equal 'app/views/users/show.html.slim', output
  end

  def test_determine_output_filename_phlex_to_haml
    input = 'app/views/users/edit.rb'
    output = @cli.send(:determine_output_filename, input, 'phlex', 'haml')
    assert_equal 'app/views/users/edit.html.haml', output
  end

  def test_determine_output_filename_slim_to_haml
    input = 'app/views/posts/index.html.slim'
    output = @cli.send(:determine_output_filename, input, 'slim', 'haml')
    assert_equal 'app/views/posts/index.html.haml', output
  end

  def test_determine_output_filename_haml_to_erb
    input = 'app/views/posts/show.html.haml'
    output = @cli.send(:determine_output_filename, input, 'haml', 'erb')
    assert_equal 'app/views/posts/show.html.erb', output
  end

  def test_determine_output_filename_without_html_prefix
    input = 'config/template.erb'
    output = @cli.send(:determine_output_filename, input, 'erb', 'slim')
    assert_equal 'config/template.slim', output
  end

  def test_determine_output_filename_phlex_without_html_prefix
    input = 'config/template.erb'
    output = @cli.send(:determine_output_filename, input, 'erb', 'phlex')
    assert_equal 'config/template.rb', output
  end
end
