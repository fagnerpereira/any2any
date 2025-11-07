# frozen_string_literal: true

require 'test_helper'

class TestOptimizer < Minitest::Test
  def setup
    @optimizer = Any2Any::Transformers::Optimizer.new
  end

  def test_optimize_template
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    result = @optimizer.transform(ir)
    assert_instance_of Any2Any::IR::Template, result
  end

  def test_optimize_returns_same_ir
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    result = @optimizer.transform(ir)
    # Optimizer currently just returns the same IR
    assert_equal ir, result
  end
end
