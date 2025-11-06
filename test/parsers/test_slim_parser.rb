# frozen_string_literal: true

require 'test_helper'

class TestSlimParser < Minitest::Test
  def setup
    @parser = TemplateConverter::Parsers::SlimParser.new
  end

  def test_parses_simple_div
    source = 'div'
    ir = @parser.parse(source)

    assert_instance_of TemplateConverter::IR::Template, ir
    assert_equal 1, ir.children.length
    assert_instance_of TemplateConverter::IR::Element, ir.children.first
    assert_equal 'div', ir.children.first.tag_name
  end

  def test_parses_nested_elements
    source = "div\n  p Hello"
    ir = @parser.parse(source)

    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 1, div.children.length

    p_tag = div.children.first
    assert_instance_of TemplateConverter::IR::Element, p_tag
    assert_equal 'p', p_tag.tag_name
  end

  def test_parses_static_content
    source = "div\n  | Hello World"
    ir = @parser.parse(source)

    div = ir.children.first
    assert_equal 1, div.children.length
    content = div.children.first
    assert_instance_of TemplateConverter::IR::StaticContent, content
    assert_equal 'Hello World', content.text
  end

  def test_parses_expression
    source = "p= @name"
    ir = @parser.parse(source)

    p_tag = ir.children.first
    assert_equal 'p', p_tag.tag_name
    assert_equal 1, p_tag.children.length

    expr = p_tag.children.first
    assert_instance_of TemplateConverter::IR::Expression, expr
    assert_equal '@name', expr.code
    assert_equal true, expr.escaped
  end

  def test_parses_fixture
    source = read_fixture(:slim, :simple_div)
    ir = @parser.parse(source)

    assert_instance_of TemplateConverter::IR::Template, ir
    assert_equal 1, ir.children.length
    assert_equal 'div', ir.children.first.tag_name
  end

  def test_parses_fixture_nested
    source = read_fixture(:slim, :nested)
    ir = @parser.parse(source)

    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 1, div.children.length
    assert_equal 'p', div.children.first.tag_name
  end
end
