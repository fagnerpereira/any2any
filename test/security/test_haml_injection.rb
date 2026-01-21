# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestHamlInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::HamlGenerator.new
  end

  def test_root_content_injection
    # Static content at root level (not inside element) MUST be escaped
    text = "- system('rm -rf /')"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    # Must be escaped because it starts the line
    assert_match(/^\\- system/, output, 'Root content starting with - must be escaped')
    refute_match(/^- system/, output, 'Root content starting with - must not be unescaped')
  end

  def test_nested_single_line_injection
    # Single line inside element is inlined, which is safe without escaping start char
    text = "- system('rm -rf /')"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Expect inline: %div - system...
    assert_match(/%div - system/, output)
    # Ensure no backslash added unnecessarily (as it would be visible in output)
    refute_match(/\\- system/, output)
  end

  def test_multiline_injection
    # Multiline content forces nesting. Lines starting with - must be escaped.
    text = "safe\n- system('rm -rf /')"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Should be indented and escaped
    assert_match(/\\- system/, output, 'Multiline script marker should be escaped')
    refute_match(/^\s*- system/, output, 'Multiline script marker should not be unescaped')
  end

  def test_tag_injection_inline
    # % within text, inlined
    text = '%body'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Inline: %div %body -> Safe
    assert_match(/%div %body/, output)
    refute_match(/\\%body/, output)
  end

  def test_indentation_integrity
    # Multiline text should be indented correctly
    text = "line1\nline2"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    lines = output.lines.map(&:chomp)
    assert_equal '%div', lines[0]
    assert_equal '  line1', lines[1]
    assert_equal '  line2', lines[2]
  end

  def test_inline_optimization_disabled_for_multiline
    # If text is multiline, it should not be inlined
    text = "line1\nline2"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    refute_match(/%div line1/, output, 'Multiline text should not be inlined')
  end

  def test_interpolation_injection_inline
    # #{...} should be escaped even in inline content
    text = "\#{system('echo HACKED')}"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Expect escaped interpolation: %div \#{...}
    assert_match(/\\#\{/, output, 'Interpolation should be escaped in inline content')
  end

  def test_interpolation_injection_multiline
    # #{...} should be escaped in multiline content
    text = "safe\n\#{system('echo HACKED')}"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    # Expect escaped interpolation
    assert_match(/\\#\{/, output, 'Interpolation should be escaped in multiline content')
  end

  def test_interpolation_midline
    # #{...} should be escaped even if not at start of line
    text = "safe \#{system('echo HACKED')}"
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    assert_match(/safe \\#\{/, output, 'Midline interpolation should be escaped')
  end

  def test_filter_injection
    # Lines starting with : should be escaped to prevent filter execution
    text = ':javascript'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @generator.generate(template)

    # Expect escaped filter: \:javascript
    assert_match(/\\:javascript/, output, 'Filter marker should be escaped')
    refute_match(/^:javascript/, output, 'Filter marker should not be unescaped')
  end
end
