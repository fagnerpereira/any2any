# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../lib/any2any"
require_relative "../../lib/any2any/generators/erb_generator"
require_relative "../../lib/any2any/ir/template"
require_relative "../../lib/any2any/ir/static_content"

class ErbGeneratorInjectionTest < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_static_content_should_be_escaped
    # Attacker tries to inject code via static content
    malicious_text = "Hello <% system('echo pwned') %> World"

    # Construct IR with this text
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: malicious_text)
      ]
    )

    # Generate ERB
    output = @generator.generate(ir)

    # In ERB, <%% escapes to <% literal.
    # So we expect the output to be "Hello <%% system('echo pwned') %> World"
    # If it is not escaped, it will be "Hello <% system('echo pwned') %> World", which is the vulnerability.

    # Assert that it IS escaped (this test is expected to fail initially)
    assert_includes output, "<%% system('echo pwned') %>", "Static content starting with <% should be escaped to <%%"
    refute_includes output, "<% system", "Static content should not contain unescaped <% tag start"
  end

  def test_static_content_with_multiple_tags
      text = "One <% tag %> Two <%= expr %>"
      ir = Any2Any::IR::Template.new(
        children: [
            Any2Any::IR::StaticContent.new(text: text)
        ]
      )

      output = @generator.generate(ir)

      assert_includes output, "One <%% tag %> Two <%%= expr %>"
  end
end
