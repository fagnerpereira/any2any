# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestErbInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_erb_tag_injection
    # Simulates IR where a static text node contains ERB tags
    # which should be treated as literal text in the output.
    text_with_injection = '<% system("echo HACKED") %>'

    # Create a simple IR: <div><% system("echo HACKED") %></div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect the opening tag to be escaped to <%%
    assert_match(/<%% system\("echo HACKED"\) %>/, output, "ERB start tag should be escaped")
    refute_match(/<% system/, output, "Output should not contain unescaped ERB tag")
  end

  def test_erb_expression_injection
    # Simulates injection of expression tags <%= %>
    text_with_injection = '<%= @secret %>'

    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    assert_match(/<%%= @secret %>/, output, "ERB expression tag should be escaped")
  end
end
