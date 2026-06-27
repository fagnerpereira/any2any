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
    text_with_injection = '<% puts "HACKED" %>'

    # Create a simple IR: <div><% puts "HACKED" %></div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Check if the output is safely escaped
    # We expect: <div><%% puts "HACKED" %></div>

    refute_match(/<% puts "HACKED" %>/, output, "Output should not contain unescaped ERB tags")
    assert_match(/<%% puts "HACKED" %>/, output, "ERB start tag should be escaped")
  end

  def test_erb_output_tag_injection
    # Test injection with output tag <%=
    text_with_injection = '<%= system("rm -rf /") %>'

    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    # We expect <%%= system("rm -rf /") %>
    assert_match(/<%%= system/, output, "ERB output tag should be escaped")
  end

  def test_attribute_injection
    # Test injection in attributes.
    # Note: Attributes in ERB are HTML strings, so standard HTML escaping applies.
    # However, if an attribute value contains <% it might be executed.

    attribute_value = '<% puts "HACKED" %>'

    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: { 'data-foo' => attribute_value }
    )

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # ErbGenerator uses escape_attribute which escapes < to &lt;
    # So <% becomes &lt;%

    assert_match(/data-foo="&lt;% puts &quot;HACKED&quot; %&gt;"/, output, "Attributes should be HTML escaped")
  end
end
