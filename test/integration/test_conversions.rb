# frozen_string_literal: true

require 'test_helper'

class TestConversions < Minitest::Test
  def test_slim_to_erb
    slim_source = "div\n  p Hello"
    result = Any2Any.convert(slim_source, from: :slim, to: :erb)
    output = result[:output]

    assert output.include?('<div>')
    assert output.include?('<p>')
    assert output.include?('</p>')
    assert output.include?('</div>')
  end

  def test_erb_to_slim
    erb_source = "<div>\n  <p>Hello</p>\n</div>"
    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('div')
    assert output.include?('p')
  end

  def test_simple_div_slim_to_erb
    slim_source = 'div'
    result = Any2Any.convert(slim_source, from: :slim, to: :erb)
    output = result[:output]

    assert output.include?('<div')
    assert output.include?('</div>')
  end

  def test_slim_to_haml
    slim_source = 'div'
    result = Any2Any.convert(slim_source, from: :slim, to: :haml)
    output = result[:output]

    assert output.include?('%div')
  end

  def test_haml_to_slim
    haml_source = '%div'
    result = Any2Any.convert(haml_source, from: :haml, to: :slim)
    output = result[:output]

    assert output.include?('div')
  end

  def test_erb_with_expression
    erb_source = "<p><%= @name %></p>"
    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('= @name')
  end

  def test_conversion_with_validation
    slim_source = 'div'
    result = Any2Any.convert(
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
    result = Any2Any.convert(slim_source, from: :slim, to: :erb)

    assert result.is_a?(Hash)
    assert result.key?(:output)
    assert result.key?(:warnings)
    assert result.key?(:parser_warnings)
  end

  def test_unsupported_format_raises_error
    assert_raises(Any2Any::UnsupportedFormat) do
      Any2Any.convert('div', from: :invalid, to: :erb)
    end
  end

  def test_unsupported_target_format_raises_error
    assert_raises(Any2Any::UnsupportedFormat) do
      Any2Any.convert('div', from: :slim, to: :invalid)
    end
  end

  # Phlex conversion tests
  def test_erb_to_phlex
    erb_source = "<div><p>Hello</p></div>"
    result = Any2Any.convert(erb_source, from: :erb, to: :phlex)
    output = result[:output]

    assert output.include?('Phlex::HTML')
    assert output.include?('view_template')
    assert output.include?('div')
    assert output.include?('p')
  end

  def test_phlex_to_erb
    phlex_source = <<~RUBY
      class SimpleComponent < Phlex::HTML
        def view_template
          div do
            p { "Hello" }
          end
        end
      end
    RUBY

    result = Any2Any.convert(phlex_source, from: :phlex, to: :erb)
    output = result[:output]

    assert output.include?('<div>')
    assert output.include?('<p>')
    assert output.include?('Hello')
  end

  def test_slim_to_phlex
    slim_source = "div\n  p Hello"
    result = Any2Any.convert(slim_source, from: :slim, to: :phlex)
    output = result[:output]

    assert output.include?('Phlex::HTML')
    assert output.include?('div')
  end

  def test_haml_to_phlex
    haml_source = "%div\n  %p Hello"
    result = Any2Any.convert(haml_source, from: :haml, to: :phlex)
    output = result[:output]

    assert output.include?('Phlex::HTML')
    assert output.include?('div')
  end

  def test_phlex_to_slim
    phlex_source = <<~RUBY
      class SimpleComponent < Phlex::HTML
        def view_template
          div
        end
      end
    RUBY

    result = Any2Any.convert(phlex_source, from: :phlex, to: :slim)
    output = result[:output]

    assert output.include?('div')
  end

  def test_phlex_to_haml
    phlex_source = <<~RUBY
      class SimpleComponent < Phlex::HTML
        def view_template
          div
        end
      end
    RUBY

    result = Any2Any.convert(phlex_source, from: :phlex, to: :haml)
    output = result[:output]

    assert output.include?('%div')
  end
end
