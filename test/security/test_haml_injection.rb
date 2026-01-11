# frozen_string_literal: true

require "test_helper"

class TestHamlInjection < Minitest::Test
  def setup
    @generator = Any2Any::Generators::HamlGenerator.new
  end

  def test_special_character_escaping
    # These characters have special meaning at the start of a HAML line
    special_chars = %w[% . # = - / !]

    special_chars.each do |char|
      text = "#{char}dangerous"
      content = Any2Any::IR::StaticContent.new(text: text)
      template = Any2Any::IR::Template.new(children: [content])

      output = @generator.generate(template)

      # Should be escaped with backslash
      assert_equal "\\#{text}", output, "Failed to escape '#{char}' at start of line"
    end
  end

  def test_multiline_indentation
    # HAML relies on indentation. Multiline static content must preserve indentation relative to the parent.
    text = "Line 1\nLine 2\nLine 3"
    content = Any2Any::IR::StaticContent.new(text: text)

    # Put it inside an element to force indentation
    element = Any2Any::IR::Element.new(
      tag_name: "div",
      children: [content]
    )
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    expected = <<~HAML.rstrip
      %div
        Line 1
        Line 2
        Line 3
    HAML

    assert_equal expected, output
  end

  def test_multiline_escaping
    # Test combination of multiline and special characters
    text = "Normal line\n- dangerous line\n. another dangerous line"
    content = Any2Any::IR::StaticContent.new(text: text)

    element = Any2Any::IR::Element.new(
      tag_name: "div",
      children: [content]
    )
    template = Any2Any::IR::Template.new(children: [element])

    output = @generator.generate(template)

    expected = <<~HAML.rstrip
      %div
        Normal line
        \\- dangerous line
        \\. another dangerous line
    HAML

    assert_equal expected, output
  end
end
