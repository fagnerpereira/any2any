# frozen_string_literal: true

require 'test_helper'

class TestValidator < Minitest::Test
  def setup
    @validator = Any2Any::Transformers::Validator.new
  end

  def test_validate_template
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    result = @validator.transform(ir)
    assert_instance_of Any2Any::IR::Template, result
  end

  def test_validate_returns_same_ir
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    result = @validator.transform(ir)
    # Validator currently just returns the same IR
    assert_equal ir, result
  end
end
