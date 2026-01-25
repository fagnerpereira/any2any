# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestErbInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_tag_injection
    # Simulates IR where a static text node contains ERB tags
    # which should be escaped in the output to prevent execution.
    text_with_injection = 'Safe text <% system("echo HACKED") %>'

    # Create a simple IR: <div>Safe text <% ... %></div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect: <div>Safe text <%% system("echo HACKED") %></div>
    # The <% should be escaped to <%%

    # Check that it DOES NOT contain unescaped tag
    refute_match(/<% system/, output, "Output should not contain unescaped ERB tag")

    # Check that it DOES contain escaped tag
    assert_match(/<%% system/, output, "ERB tag should be escaped to <%%")
  end

  def test_multi_line_injection
    text_with_injection = "Line 1\n<% system('rm -rf /') %>"

    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    refute_match(/^<% system/, output, "Multiline injection should be prevented")
    assert_match(/<%% system/, output, "Multiline ERB tag should be escaped")
  end
end
