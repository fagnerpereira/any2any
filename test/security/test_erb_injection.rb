# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestErbInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_erb_tag_injection
    # Simulates IR where a static text node contains ERB syntax
    # which should be treated as literal text in the output.
    text_with_injection = '<% system("echo HACKED") %>'

    # Create a simple IR: static content
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    # We expect the opening tag to be escaped to <%%
    assert_match(/<%% system\("echo HACKED"\) %>/, output, "ERB tags in static content should be escaped")
    refute_match(/^<% system/, output, "Output should not contain unescaped ERB tags")
  end

  def test_escaped_erb_tag_preservation
    # If the text is already <%% (literal <% in ERB), it should become <%% (literal <%) in the output
    # "<%" -> "<%%". So "<%%" -> "<%%%"

    text = "<%%"

    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    assert_equal "<%%%", output
  end

  def test_closing_tag_does_not_need_escaping
    text = "%>"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)
    assert_equal "%>", output
  end
end
