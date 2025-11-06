# frozen_string_literal: true

require 'test_helper'

class TestConversions < Minitest::Test
  def test_slim_to_erb
    slim_source = "div\n  p Hello"
    result = TemplateConverter.convert(slim_source, from: :slim, to: :erb)
    output = result[:output]

    assert output.include?('<div>')
    assert output.include?('<p>')
    assert output.include?('</p>')
    assert output.include?('</div>')
  end

  def test_erb_to_slim
    erb_source = "<div>\n  <p>Hello</p>\n</div>"
    result = TemplateConverter.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('div')
    assert output.include?('p')
  end

  def test_simple_div_slim_to_erb
    slim_source = 'div'
    result = TemplateConverter.convert(slim_source, from: :slim, to: :erb)
    output = result[:output]

    assert output.include?('<div')
    assert output.include?('/>')
  end

  def test_slim_to_haml
    slim_source = 'div'
    result = TemplateConverter.convert(slim_source, from: :slim, to: :haml)
    output = result[:output]

    assert output.include?('%div')
  end

  def test_haml_to_slim
    haml_source = '%div'
    result = TemplateConverter.convert(haml_source, from: :haml, to: :slim)
    output = result[:output]

    assert output.include?('div')
  end

  def test_erb_with_expression
    erb_source = "<p><%= @name %></p>"
    result = TemplateConverter.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('= @name')
  end

  def test_conversion_with_validation
    slim_source = 'div'
    result = TemplateConverter.convert(
      slim_source,
      from: :slim,
      to: :erb,
      options: { validate: true }
    )
    output = result[:output]

    assert output.include?('<div')
  end

  def test_conversion_returns_result_hash
    slim_source = 'div'
    result = TemplateConverter.convert(slim_source, from: :slim, to: :erb)

    assert result.is_a?(Hash)
    assert result.key?(:output)
    assert result.key?(:warnings)
    assert result.key?(:parser_warnings)
  end

  def test_unsupported_format_raises_error
    assert_raises(TemplateConverter::UnsupportedFormat) do
      TemplateConverter.convert('div', from: :invalid, to: :erb)
    end
  end

  def test_unsupported_target_format_raises_error
    assert_raises(TemplateConverter::UnsupportedFormat) do
      TemplateConverter.convert('div', from: :slim, to: :invalid)
    end
  end
end
