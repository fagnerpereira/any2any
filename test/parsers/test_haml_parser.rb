# frozen_string_literal: true

require 'test_helper'

class TestHamlParser < Minitest::Test
  def setup
    @parser = TemplateConverter::Parsers::HamlParser.new
  end

  def test_parses_simple_div
    source = read_fixture(:haml, :simple)
    ir = @parser.parse(source)

    assert_instance_of TemplateConverter::IR::Template, ir
    assert_equal 1, ir.children.length

    element = ir.children.first
    assert_instance_of TemplateConverter::IR::Element, element
    assert_equal 'div', element.tag_name
  end

  def test_parses_nested
    source = read_fixture(:haml, :nested)
    ir = @parser.parse(source)

    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 1, div.children.length
    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name
  end

  def test_parses_expression
    source = "= @name"
    ir = @parser.parse(source)

    expr = ir.children.first
    assert_instance_of TemplateConverter::IR::Expression, expr
    assert_equal '@name', expr.code
    assert_equal true, expr.escaped
  end

  def test_parses_comments
    visible = "/ visible"
    ir = @parser.parse(visible)
    comment = ir.children.first
    assert_instance_of TemplateConverter::IR::Comment, comment
    assert_equal true, comment.html_visible

    invisible = "-# hidden"
    ir2 = @parser.parse(invisible)
    comment2 = ir2.children.first
    assert_instance_of TemplateConverter::IR::Comment, comment2
    assert_equal false, comment2.html_visible
  end
end
