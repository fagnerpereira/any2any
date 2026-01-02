# frozen_string_literal: true

require "test_helper"

class TestPhlexGeneratorSecurity < Minitest::Test
  def setup
    @generator = Any2Any::Generators::PhlexGenerator.new
  end

  def test_generates_safe_static_content_with_interpolation
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: '#{system("echo vulnerable")}')
      ]
    )

    output = @generator.generate(ir)

    # Should escape the hash symbol to prevent interpolation
    assert_match(/plain "\\\#{system\(\\"echo vulnerable\\"\)}"/, output)
  end

  def test_generates_safe_static_content_with_quotes
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: 'text with "quotes"')
      ]
    )

    output = @generator.generate(ir)

    # Should escape quotes
    assert_match(/plain "text with \\"quotes\\""/, output)
  end

  def test_generates_safe_static_content_with_backslashes
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: 'text with \\ backslash')
      ]
    )

    output = @generator.generate(ir)

    # Should escape backslash
    assert_match(/plain "text with \\\\ backslash"/, output)
  end
end
