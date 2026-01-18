# frozen_string_literal: true

require "test_helper"
require "any2any/generators/erb_generator"

class TestErbGeneratorSecurity < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_escapes_erb_tags_in_static_content
    # The vulnerability: static content containing "<%" was output as-is,
    # allowing for template injection / arbitrary code execution if the
    # generated ERB is evaluated.
    # Fix: escape "<%" to "<%%".

    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::StaticContent.new(text: "Hello <% system('rm -rf /') %>")
    ])

    output = @generator.generate(ir)

    # We expect the opening tag to be escaped
    assert_includes output, "Hello <%% system('rm -rf /') %>"
    refute_includes output, "Hello <% system"
  end

  def test_escapes_multiple_erb_tags
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::StaticContent.new(text: "<% 1 %> middle <% 2 %>")
    ])

    output = @generator.generate(ir)

    assert_equal "<%% 1 %> middle <%% 2 %>", output
  end
end
