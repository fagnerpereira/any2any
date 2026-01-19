# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestErbSSTI < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_static_content_injection
    # Simulates IR where a static text node contains ERB tags
    # which should be treated as literal text in the output.
    text_with_injection = '<% system("echo HACKED") %>'

    # Create a simple IR: <div><% system("echo HACKED") %></div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect: <div><%% system("echo HACKED") %></div>

    # Check that it's NOT just the raw injection
    refute_match(/<div><% system/, output, "Output should not contain unescaped ERB tag")

    # Check that it IS escaped
    assert_match(/<div><%% system/, output, "ERB start tag should be escaped")
  end
end
