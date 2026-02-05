# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'minitest/autorun'
require 'any2any/errors'
require 'any2any/ir/node'
require 'any2any/ir/template'
require 'any2any/ir/element'
require 'any2any/ir/expression'
require 'any2any/ir/block'
require 'any2any/ir/conditional'
require 'any2any/ir/loop'
require 'any2any/ir/static_content'
require 'any2any/ir/comment'
require 'any2any/generators/base_generator'
require 'any2any/generators/haml_generator'

class TestHamlInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::HamlGenerator.new
  end

  def test_start_of_line_injection
    # Text starting with '-' should be escaped
    text = "- system('rm -rf /')"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    # We put it in a div to ensure it's not inline (force block generation)
    # Though existing generator inline optimization might handle it differently,
    # we use multiple children to force block.
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [
      static_content,
      Any2Any::IR::StaticContent.new(text: "other")
    ])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect:
    # %div
    #   \- system('rm -rf /')
    #   other

    puts "\nActual Output (Injection):\n#{output}\n"

    assert_match(/\\- system/, output, "Start of line '-' should be escaped")
    refute_match(/^\s*- system/, output, "Start of line '-' should NOT be unescaped")
  end

  def test_multiline_content_indentation
    # Text with multiple lines should be correctly indented
    text = "line1\nline2"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect:
    # %div
    #   line1
    #   line2

    puts "\nMultiline Output:\n#{output}\n"

    # Check that line2 is indented (has at least 2 spaces)
    assert_match(/\n  line2/, output, "Second line should be indented")
  end

  def test_various_special_chars
    # Test other special chars: %, #, ., =, ~, /, !
    chars = ['%', '#', '.', '=', '~', '/', '!', ':', '&', '\\']

    chars.each do |char|
      text = "#{char} dangerous"
      # Force block
      element = Any2Any::IR::Element.new(tag_name: 'div', children: [
        Any2Any::IR::StaticContent.new(text: text),
        Any2Any::IR::StaticContent.new(text: "other")
      ])
      template = Any2Any::IR::Template.new(children: [element])

      output = @generator.generate(template)

      expected_escaped = "\\#{char}"
      # For backslash, it becomes \\ (regex escaped \\\\)
      if char == '\\'
         expected_escaped = "\\\\"
      end

      assert_match(/\\#{Regexp.escape(char)}/, output, "Start of line '#{char}' should be escaped")
    end
  end
end
