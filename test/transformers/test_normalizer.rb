# frozen_string_literal: true

require 'test_helper'

class TestNormalizer < Minitest::Test
  def setup
    @normalizer = Any2Any::Transformers::Normalizer.new
  end

  def test_normalize_template
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    result = @normalizer.transform(ir)
    assert_instance_of Any2Any::IR::Template, result
    assert_equal 1, result.children.length
  end

  def test_normalize_returns_same_ir
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    result = @normalizer.transform(ir)
    # Normalizer currently just returns the same IR
    assert_equal ir, result
  end
end
