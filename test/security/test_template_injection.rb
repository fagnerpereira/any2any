# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestTemplateInjection < Minitest::Test
  def setup
    @erb_generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_erb_static_content_escaping
    # Test that <% is escaped to <%% in static content
    payload = '<% system("rm -rf /") %>'
    static_content = Any2Any::IR::StaticContent.new(text: payload)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @erb_generator.generate(template)

    # We expect <%% system("rm -rf /") %>
    expected = '<%% system("rm -rf /") %>'
    assert_equal expected, output, "ERB tags in static content should be escaped"
  end

  def test_erb_static_content_with_surrounding_text
    payload = 'Hello <% world %>'
    static_content = Any2Any::IR::StaticContent.new(text: payload)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @erb_generator.generate(template)

    expected = 'Hello <%% world %>'
    assert_equal expected, output
  end

  # Ensure closing tags are left alone if they appear without opening tags or are part of the text
  def test_erb_closing_tag_only
    payload = 'Just a closing tag %>'
    static_content = Any2Any::IR::StaticContent.new(text: payload)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @erb_generator.generate(template)

    assert_equal 'Just a closing tag %>', output
  end
end
