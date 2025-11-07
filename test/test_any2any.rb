# frozen_string_literal: true

require 'test_helper'

class TestAny2Any < Minitest::Test
  def test_any2any_module_exists
    assert_kind_of Module, Any2Any
  end

  def test_any2any_convert_method
    result = Any2Any.convert('<div>Test</div>', from: :erb, to: :slim)
    
    assert_instance_of Hash, result
    assert result[:output]
  end

  def test_template_converter_alias
    # TemplateConverter should be the same as Any2Any
    assert_equal Any2Any, Object.const_get('TemplateConverter')
  end

  def test_template_converter_convert
    result = Object.const_get('TemplateConverter').convert('<div>Test</div>', from: :erb, to: :slim)
    
    assert_instance_of Hash, result
    assert result[:output]
  end

  def test_version_constant_exists
    assert Any2Any::VERSION
    assert_match(/\d+\.\d+\.\d+/, Any2Any::VERSION)
  end

  def test_module_structure
    # Test that key modules exist
    assert Any2Any::Parsers
    assert Any2Any::Generators
    assert Any2Any::IR
    assert Any2Any::Transformers
  end

  def test_parser_classes_exist
    assert Any2Any::Parsers::ErbParser
    assert Any2Any::Parsers::SlimParser
    assert Any2Any::Parsers::HamlParser
    assert Any2Any::Parsers::PhlexParser
  end

  def test_generator_classes_exist
    assert Any2Any::Generators::ErbGenerator
    assert Any2Any::Generators::SlimGenerator
    assert Any2Any::Generators::HamlGenerator
    assert Any2Any::Generators::PhlexGenerator
  end

  def test_ir_classes_exist
    assert Any2Any::IR::Template
    assert Any2Any::IR::Element
    assert Any2Any::IR::Expression
    assert Any2Any::IR::Block
    assert Any2Any::IR::StaticContent
    assert Any2Any::IR::Comment
    assert Any2Any::IR::Conditional
    assert Any2Any::IR::Loop
  end

  def test_transformer_classes_exist
    assert Any2Any::Transformers::Normalizer
    assert Any2Any::Transformers::Optimizer
    assert Any2Any::Transformers::Validator
  end

  def test_converter_class_exists
    assert Any2Any::Converter
  end

  def test_cli_class_exists
    assert Object.const_get('TemplateConverter')::CLI
  end
end
