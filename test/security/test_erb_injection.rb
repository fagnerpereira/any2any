# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestErbInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_static_content_escaping
    # Simulates IR where a static text node contains ERB tags
    # which should be treated as literal text in the output to prevent SSTI.
    text_with_injection = "<% system('rm -rf /') %>"

    # Create a simple IR: <div><% system('rm -rf /') %></div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect the opening tag to be escaped as <%%
    expected_escaped = "<%% system('rm -rf /') %>"

    assert_includes output, expected_escaped, "ERB tags in static content must be escaped"
    refute_includes output, "<div><% ", "Output should not contain unescaped ERB tags"
  end

  def test_static_content_double_percent_escaping
    # Ensures that text which already looks like an escaped tag is handled correctly.
    # If the static content is "<%%" (which represents a literal "<%" in some contexts),
    # the generator should output "<%%%" (which renders as "<%%" in ERB).

    text = "<%%"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    # We test the private method directly or via generate
    output = @generator.send(:generate_static_content, static_content)

    # gsub('<%', '<%%') on "<%%" results in "<%%%"
    assert_equal "<%%%", output
  end
end
