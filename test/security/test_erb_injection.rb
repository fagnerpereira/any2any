# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestErbInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_tag_injection
    # Simulates IR where a static text node contains ERB tags
    # which should be treated as literal text in the output.
    text_with_injection = '<% system("echo HACKED") %>'

    # Create a simple IR: <div><% system("echo HACKED") %></div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect the <% to be escaped to <%% in ERB so it prints literally
    expected_escaped = '<%% system("echo HACKED") %>'

    assert_includes output, expected_escaped, "ERB tags in static content should be escaped to <%%"
    refute_includes output, "<div>#{text_with_injection}</div>", "Output should not contain raw unescaped ERB tags"
  end
end
