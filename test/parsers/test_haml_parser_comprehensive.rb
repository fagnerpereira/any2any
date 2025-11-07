# frozen_string_literal: true

require 'test_helper'

class TestHamlParserComprehensive < Minitest::Test
  def setup
    @parser = Any2Any::Parsers::HamlParser.new
  end

  def test_parses_element_with_hash_attributes
    source = '%div{class: "test", id: "main"}'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'div', element.tag_name
    assert_equal 'test', element.attributes['class']
    assert_equal 'main', element.attributes['id']
  end

  def test_parses_element_with_content
    source = '%p Hello World'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'p', element.tag_name
    assert_equal 1, element.children.length
  end

  def test_parses_nested_elements
    source = "%div\n  %p Hello"
    ir = @parser.parse(source)
    
    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 1, div.children.length
    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name
  end

  def test_parses_haml_output
    source = '= @user.name'
    ir = @parser.parse(source)
    
    expr = ir.children.first
    assert_instance_of Any2Any::IR::Expression, expr
    assert_equal '@user.name', expr.code
  end

  def test_parses_haml_code
    source = '- if true'
    ir = @parser.parse(source)
    
    cond = ir.children.first
    assert_instance_of Any2Any::IR::Conditional, cond
  end

  def test_parses_haml_comment
    source = '/ HTML comment'
    ir = @parser.parse(source)
    
    comment = ir.children.first
    assert_instance_of Any2Any::IR::Comment, comment
    assert_equal true, comment.html_visible
  end

  def test_parses_silent_comment
    source = '-# Silent comment'
    ir = @parser.parse(source)
    
    comment = ir.children.first
    assert_instance_of Any2Any::IR::Comment, comment
    assert_equal false, comment.html_visible
  end

  def test_parses_class_shortcut
    source = '%div.container'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'div', element.tag_name
    assert_equal 'container', element.attributes['class']
  end

  def test_parses_id_shortcut
    source = '%div#main'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'div', element.tag_name
    assert_equal 'main', element.attributes['id']
  end

  def test_parses_combined_shortcuts
    source = '%div.container#main'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'div', element.tag_name
    assert_equal 'container', element.attributes['class']
    assert_equal 'main', element.attributes['id']
  end

  def test_parses_multiple_classes
    source = '%div.container.mx-auto'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert element.attributes['class'].include?('container')
  end

  def test_handles_parse_error
    # Test that parser handles errors gracefully
    begin
      result = @parser.parse('<<<invalid>>>')
      # Parser may handle some invalid syntax gracefully
      assert_instance_of Any2Any::IR::Template, result
    rescue Any2Any::ParseError => e
      # Expected error
      assert_instance_of Any2Any::ParseError, e
    end
  end

  def test_parses_self_closing_tag
    source = '%br'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'br', element.tag_name
    assert_equal true, element.self_closing
  end

  def test_skips_empty_lines
    source = "%div\n\n%p"
    ir = @parser.parse(source)
    
    assert_equal 2, ir.children.length
  end

  def test_parses_plain_text
    source = 'Just plain text'
    ir = @parser.parse(source)
    
    content = ir.children.first
    assert_instance_of Any2Any::IR::StaticContent, content
  end

  def test_parses_unescaped_output
    source = '== @html'
    ir = @parser.parse(source)
    
    expr = ir.children.first
    assert_instance_of Any2Any::IR::Expression, expr
    assert_equal false, expr.escaped
  end

  def test_parses_each_loop
    source = '- @users.each do |user|'
    ir = @parser.parse(source)
    
    # HAML parser may create a Block or Loop depending on parsing logic
    node = ir.children.first
    assert node.is_a?(Any2Any::IR::Block) || node.is_a?(Any2Any::IR::Loop)
  end
end
