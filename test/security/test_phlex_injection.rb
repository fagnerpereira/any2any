# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestPhlexInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::PhlexGenerator.new
  end

  def test_interpolation_injection
    # Simulates IR where a static text node contains Ruby interpolation syntax
    # which should be treated as literal text in the output.
    text_with_injection = '#{system("echo HACKED")}'

    # Create a simple IR: <div>#{system("echo HACKED")}</div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Check if the output is safely escaped
    # We expect: plain "\#{system(\"echo HACKED\")}"

    refute_match(/plain "#{Regexp.escape(text_with_injection)}"/, output, "Output should not contain unescaped interpolation")
    assert_match(/\\#\{/, output, "Interpolation start should be escaped")
  end

  def test_backslash_injection
     # Backslash at the end of a string can escape the closing quote
     # value = "foo\"" -> escaped to "foo\\"" -> inside string "foo\\"" -> correct

     text_ending_in_backslash = 'foo\\'

     static_content = Any2Any::IR::StaticContent.new(text: text_ending_in_backslash)
     element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

     template = Any2Any::IR::Template.new(children: [element])

     output = @generator.generate(template)

     # We expect double backslash in the Ruby code string literal
     assert_match(/plain "foo\\\\"/, output, "Backslashes should be escaped")
  end

  def test_attribute_injection
    # Test injection in attributes
    attribute_value = '"><script>alert(1)</script>'

    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: { 'data-foo' => attribute_value }
    )

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    assert_match(/data-foo: ".*\\".*"/, output, "Double quotes in attributes should be escaped")
    assert_match(/\\"><script>/, output, "Injection payload should be escaped")
  end
end
