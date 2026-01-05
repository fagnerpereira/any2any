# frozen_string_literal: true

require "test_helper"

class TestPhlexSecurity < Minitest::Test
  def setup
    @generator = Any2Any::Generators::PhlexGenerator.new
  end

  def test_prevents_code_injection_in_static_content
    # User input that tries to break out of the string and execute code
    # If the output is: plain "User input #{system('ls')} here"
    # It will execute the code when the Phlex component runs.
    malicious_text = 'User input #{system("echo hacked")} here'

    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: malicious_text)
      ]
    )

    output = @generator.generate(ir)

    # We expect the #{ to be escaped so it's not interpolated
    # The output code should look something like: plain "User input \#{system(\"echo hacked\")} here"
    # Or properly escaped to prevent interpolation.

    # Currently it probably generates: plain "User input #{system(\"echo hacked\")} here"
    # which effectively executes the code.

    refute_match(/#{Regexp.escape('plain "User input #{system(\"echo hacked\")} here"')}/, output, "Should not allow interpolation in static content")
    assert_match(/\\#\{/, output, "Should escape interpolation sequences")
  end

  def test_prevents_code_injection_in_attributes
    # Similar attack in attributes
    malicious_attr = 'val" + system("echo hacked").to_s + "'

    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(
          tag_name: "div",
          attributes: {"data-test" => malicious_attr}
        )
      ]
    )

    output = @generator.generate(ir)

    # If unescaped, it might look like: data-test: "val" + system("echo hacked").to_s + ""
    # We want it to be: data-test: "val\" + system(\"echo hacked\").to_s + \""
    # But wait, if it's "val" + ... that would be valid ruby code if not in a string.
    # The generator wraps values in quotes: "#{key}: \"#{escape_quotes(value)}\""

    # So if malicious_attr is `val"`, output becomes `"val\""` which is safe.
    # But if malicious_attr contains interpolation `#{}`

    malicious_attr_interp = '#{system("echo hacked")}'
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(
          tag_name: "div",
          attributes: {"data-test" => malicious_attr_interp}
        )
      ]
    )

    output = @generator.generate(ir)

    assert_match(/\\#\{/, output, "Should escape interpolation sequences in attributes")
  end

  def test_escapes_backslashes
    # If we have a backslash at the end, it might escape the closing quote
    # text: "foo\"
    # escaped: "foo\\"
    # in code: plain "foo\\" -> string is "foo\"

    # If we don't escape backslash:
    # text: "foo\"
    # escaped: "foo\""  (assuming we only escape quotes)
    # in code: plain "foo\"" -> Syntax error? Or escapes the quote?
    # plain "foo\"" -> The string doesn't end! The quote is escaped.

    text = 'foo\\'
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: text)
      ]
    )

    output = @generator.generate(ir)

    # Should be escaped to double backslash
    assert_match(/foo\\\\/, output, "Should escape backslashes")
  end
end
