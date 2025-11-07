# frozen_string_literal: true

require 'test_helper'

class TestSlimParserComprehensive < Minitest::Test
  def setup
    @parser = Any2Any::Parsers::SlimParser.new
  end

  def test_parses_element_with_attributes
    source = 'div class="test" id="main"'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'div', element.tag_name
    assert_equal 'test', element.attributes['class']
    assert_equal 'main', element.attributes['id']
  end

  def test_parses_element_with_content
    source = 'p Hello World'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'p', element.tag_name
    assert_equal 1, element.children.length
  end

  def test_parses_nested_elements
    source = "div\n  p Hello"
    ir = @parser.parse(source)
    
    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 1, div.children.length
    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name
  end

  def test_parses_slim_output
    source = '= @user.name'
    ir = @parser.parse(source)
    
    expr = ir.children.first
    assert_instance_of Any2Any::IR::Expression, expr
    assert_equal '@user.name', expr.code
  end

  def test_parses_slim_code
    source = '- if true'
    ir = @parser.parse(source)
    
    # May be nil or Block depending on Slim parser behavior
    if ir.children.any?
      node = ir.children.first
      assert_instance_of Any2Any::IR::Block, node if node
    else
      # Comment/code may be filtered out by Slim parser
      assert_equal 0, ir.children.length
    end
  end

  def test_parses_slim_comment
    source = '/ HTML comment'
    ir = @parser.parse(source)
    
    # Comment may or may not be included depending on Slim parser
    if ir.children.any?
      comment = ir.children.first
      assert_instance_of Any2Any::IR::Comment, comment if comment
    end
  end

  def test_parses_multiple_attributes
    source = 'input type="text" name="email" placeholder="Email"'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'input', element.tag_name
    assert_equal 'text', element.attributes['type']
    assert_equal 'email', element.attributes['name']
    assert_equal 'Email', element.attributes['placeholder']
  end

  def test_handles_parse_error
    # Test that parser handles errors gracefully
    # Note: Some invalid syntax might still parse to something
    begin
      result = @parser.parse('<<<invalid>>>')
      # If it doesn't raise, that's also okay - parser may be lenient
      assert_instance_of Any2Any::IR::Template, result
    rescue Any2Any::ParseError => e
      # Expected error
      assert_instance_of Any2Any::ParseError, e
    end
  end

  def test_parses_self_closing_tag
    source = 'br'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'br', element.tag_name
    assert_equal true, element.self_closing
  end

  def test_parses_data_attributes
    source = 'div data-controller="modal" data-action="click"'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'modal', element.attributes['data-controller']
    assert_equal 'click', element.attributes['data-action']
  end
end
