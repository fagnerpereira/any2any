# frozen_string_literal: true

require 'test_helper'

class PhlexSecurityTest < Minitest::Test
  def setup
    @generator = Any2Any::Generators::PhlexGenerator.new
  end

  def test_interpolation_injection_prevention
    # Payload: #{system('echo hacked')}
    # We want to ensure this is rendered as literal text, not executed as Ruby code
    payload = '#{system(\'echo hacked\')}'

    node = Any2Any::IR::StaticContent.new(text: payload)
    template = Any2Any::IR::Template.new(children: [node])

    generated_code = @generator.generate(template)

    # Check that the hash symbol is escaped or interpolation is prevented
    # Expected: plain "\#{system('echo hacked')}"
    assert_match /plain "\\#\{system/, generated_code
    refute_match /plain "#{Regexp.escape(payload)}"/, generated_code
  end

  def test_backslash_escape_prevention
    # Payload: \
    # If not escaped, this could escape the closing quote of the string literal
    payload = '\\'

    node = Any2Any::IR::StaticContent.new(text: payload)
    template = Any2Any::IR::Template.new(children: [node])

    generated_code = @generator.generate(template)

    # Expected: plain "\\"
    assert_match /plain "\\\\"/, generated_code
  end

  def test_quote_escape_prevention
    # Payload: "
    # If not escaped, this closes the string literal early
    payload = '"'

    node = Any2Any::IR::StaticContent.new(text: payload)
    template = Any2Any::IR::Template.new(children: [node])

    generated_code = @generator.generate(template)

    # Expected: plain "\""
    assert_match /plain "\\""/, generated_code
  end

  def test_complex_injection_attempt
    # Payload: " #{system('rm -rf /')} "
    payload = '" #{system(\'rm -rf /\')} "'

    node = Any2Any::IR::StaticContent.new(text: payload)
    template = Any2Any::IR::Template.new(children: [node])

    generated_code = @generator.generate(template)

    # Check that both quotes and interpolation are escaped
    # Expected: plain "\" \#{system('rm -rf /')} \""
    assert_match /plain "\\\" \\#\{system/, generated_code
  end
end
