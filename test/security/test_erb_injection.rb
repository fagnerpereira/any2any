# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestErbInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_ssti_injection
    # Simulates IR where a static text node contains ERB tag syntax
    # which should be treated as literal text in the output.
    text_with_injection = '<% system("echo HACKED") %>'

    # Create a simple IR: <div><% system("echo HACKED") %></div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect: <div><%% system("echo HACKED") %></div>
    expected_fragment = '<%% system("echo HACKED") %>'

    # It currently fails (returns raw), so this test confirms the vulnerability if it fails,
    # or confirms the fix if it passes.
    assert_match(expected_fragment, output, "ERB tags in static content should be escaped")
    refute_match(/<% system/, output, "Output should not contain unescaped ERB tags")
  end
end
