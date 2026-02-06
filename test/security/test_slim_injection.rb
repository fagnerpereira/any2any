# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestSlimInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::SlimGenerator.new
  end

  def test_interpolation_injection_in_content
    # Simulates IR where a static text node contains Ruby interpolation syntax
    # which should be treated as literal text in the output.
    text_with_injection = 'Hello #{system("echo HACKED")}'

    # Create a simple IR: <div>Hello #{system("echo HACKED")}</div>
    static_content = Any2Any::IR::StaticContent.new(text: text_with_injection)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect the interpolation to be escaped: Hello \#{system("echo HACKED")}
    assert_includes output, 'Hello \#{system("echo HACKED")}', "Interpolation should be escaped in static content"
    refute_includes output, 'Hello #{system', "Output should not contain unescaped interpolation"
  end

  def test_interpolation_injection_in_attribute
    # Test injection in attributes
    attribute_value = 'user-#{system("rm -rf /")}'

    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: { 'class' => attribute_value }
    )

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect: div class="user-\#{system("rm -rf /")}"
    # Since we are escaping attributes, quotes inside will be &quot;
    assert_includes output, 'class="user-\#{system(&quot;rm -rf /&quot;)}"', "Interpolation should be escaped in attributes"
  end

  def test_multiline_injection
    # Test that newlines in static content are handled correctly
    # If not handled, the second line might be interpreted as a tag
    text_multiline = "Line 1\nscript: alert(1)"

    static_content = Any2Any::IR::StaticContent.new(text: text_multiline)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # We expect:
    # div
    #   | Line 1
    #   | script: alert(1)

    # Or at least correct indentation for subsequent lines.
    # The current implementation likely produces:
    # div
    #   | Line 1
    # script: alert(1)  <-- this is bad, it becomes a tag 'script'

    lines = output.split("\n")
    assert lines.any? { |l| l.include?("Line 1") }

    script_line = lines.find { |l| l.include?("script: alert(1)") }
    assert script_line, "Should contain the second line"

    # Check indentation or prefix
    assert_match(/^\s*\|/, script_line.strip, "Second line of static content should be prefixed with | or indented properly")
  end

  def test_backslash_bypass
    # Test that backslashes are escaped so they cannot be used to escape the escaped interpolation
    # Input: \#{system('echo HACKED')}
    # If we only escape #{ -> \#{, we get \\#{...} which allows interpolation.
    # We want \\\#{...} so that it renders as literal \#{...}

    # Use single quotes to avoid ruby interpolation confusion in test file
    text_bypass = '\#{system(\'echo HACKED\')}'

    static_content = Any2Any::IR::StaticContent.new(text: text_bypass)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])

    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Expected output should contain \\\#{ to ensure both \ and #{ are literal
    # We expect the backslash to be escaped to \\
    # And the #{ to be escaped to \#{
    # So combined: \\\#{
    # In Ruby string literal for 3 backslashes: "\\\\\\\#{" or '\\\\\\#{' (if single quotes behave)
    # Let's use double quotes for clarity of escaping: \\ -> \
    # We want to match substring: \ \ \ # {
    # So regex or string: "\\\\\\\#{"

    assert_includes output, "\\\\\\\#{", "Backslash should be escaped to prevent bypassing interpolation escape"
  end
end
