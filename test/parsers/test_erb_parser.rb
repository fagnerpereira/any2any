# frozen_string_literal: true

require 'test_helper'

class TestErbParser < Minitest::Test
  def setup
    @parser = Any2Any::Parsers::ErbParser.new
  end

  def test_parses_simple_element
    source = read_fixture(:erb, :simple)
    ir = @parser.parse(source)

    assert_instance_of Any2Any::IR::Template, ir
    assert_equal 1, ir.children.length

    div = ir.children.first
    assert_instance_of Any2Any::IR::Element, div
    assert_equal 'div', div.tag_name
    assert_empty div.children
  end

  def test_parses_nested_with_expression
    source = read_fixture(:erb, :with_expression)
    ir = @parser.parse(source)

    assert_instance_of Any2Any::IR::Template, ir
    div = ir.children.first
    assert_equal 'div', div.tag_name
    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name

    expr = p_tag.children.first
    assert_instance_of Any2Any::IR::Expression, expr
    assert_equal '@name', expr.code
    assert_equal true, expr.escaped
  end

  def test_parses_nested
    source = read_fixture(:erb, :nested)
    ir = @parser.parse(source)

    div = ir.children.first
    assert_equal 'div', div.tag_name
    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name
  end
end
