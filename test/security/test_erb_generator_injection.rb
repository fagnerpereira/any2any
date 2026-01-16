# frozen_string_literal: true

require_relative "../test_helper"

class TestErbGeneratorInjection < Minitest::Test
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
