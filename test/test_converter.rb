# frozen_string_literal: true

require 'test_helper'

class TestConverter < Minitest::Test
  def test_converter_converts_erb_to_slim
    converter = Any2Any::Converter.new
    erb = '<div class="test">Hello</div>'
    
    result = converter.convert(erb, from: :erb, to: :slim)
    
    assert_instance_of Hash, result
    assert result[:output]
    assert result[:warnings]
    assert result[:parser_warnings]
  end

  def test_converter_with_validation
    converter = Any2Any::Converter.new(validate: true)
    erb = '<div>Hello</div>'
    
    result = converter.convert(erb, from: :erb, to: :slim)
    assert result[:output]
  end

  def test_converter_with_optimization
    converter = Any2Any::Converter.new(optimize: true)
    erb = '<div>Hello</div>'
    
    result = converter.convert(erb, from: :erb, to: :slim)
    assert result[:output]
  end

  def test_converter_raises_on_unsupported_format
    converter = Any2Any::Converter.new
    
    assert_raises(Any2Any::UnsupportedFormat) do
      converter.convert('test', from: :invalid, to: :slim)
    end
  end

  def test_converter_raises_on_unsupported_target_format
    converter = Any2Any::Converter.new
    
    assert_raises(Any2Any::UnsupportedFormat) do
      converter.convert('<div>test</div>', from: :erb, to: :invalid)
    end
  end

  def test_converter_erb_to_haml
    converter = Any2Any::Converter.new
    erb = '<div class="test">Hello</div>'
    
    result = converter.convert(erb, from: :erb, to: :haml)
    assert result[:output].include?('%div')
  end

  def test_converter_erb_to_phlex
    converter = Any2Any::Converter.new
    erb = '<div class="test">Hello</div>'
    
    result = converter.convert(erb, from: :erb, to: :phlex)
    assert result[:output].include?('Phlex::HTML')
  end

  def test_converter_slim_to_erb
    converter = Any2Any::Converter.new
    slim = 'div Hello'
    
    result = converter.convert(slim, from: :slim, to: :erb)
    assert result[:output].include?('<div>')
  end

  def test_converter_haml_to_erb
    converter = Any2Any::Converter.new
    haml = '%div Hello'
    
    result = converter.convert(haml, from: :haml, to: :erb)
    assert result[:output].include?('<div>')
  end

  def test_converter_phlex_to_erb
    converter = Any2Any::Converter.new
    phlex = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          div { "Hello" }
        end
      end
    RUBY
    
    result = converter.convert(phlex, from: :phlex, to: :erb)
    assert result[:output].include?('<div>')
  end
end
