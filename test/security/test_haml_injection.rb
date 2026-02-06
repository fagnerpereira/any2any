# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestHamlInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::HamlGenerator.new
  end

  def test_static_content_injection
    # In Haml, if a line starts with %, it's an element.
    # If static content starts with %, it should be escaped.

    text_injection = '%script alert(1)'
    static_content = Any2Any::IR::StaticContent.new(text: text_injection)
    # Wrap in a template directly as text
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    # If output is "%script alert(1)", then HAML treats it as a <script> tag!
    # It should be escaped, e.g., with a backslash or by indentation logic if implicit div is not used.
    # Actually, plain text in HAML that starts with special chars might need escaping.

    # HAML:
    # %div
    #   %script

    # If we want literal text "%script", we write:
    # \%script

    assert_match(/\\%script/, output, "Lines starting with % should be escaped")
  end

  def test_static_content_multiline_injection
      # Multiline text might need proper indentation or pipe
      text = "line1\n  line2"
      static_content = Any2Any::IR::StaticContent.new(text: text)
      template = Any2Any::IR::Template.new(children: [static_content])

      output = @generator.generate(template)

      # If indentation is messed up, it breaks.
      # But for injection:
      text_injection = "line1\n%script alert(1)"
      static_content = Any2Any::IR::StaticContent.new(text: text_injection)
      template = Any2Any::IR::Template.new(children: [static_content])

      output = @generator.generate(template)

      assert_match(/\\%script/, output, "Lines starting with % inside multiline text should be escaped or handled safely")
  end
end
