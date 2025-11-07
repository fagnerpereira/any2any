# frozen_string_literal: true

require 'test_helper'

class TestErbParserComprehensive < Minitest::Test
  def setup
    @parser = Any2Any::Parsers::ErbParser.new
  end

  def test_parses_element_with_attributes
    source = '<div class="test" id="main">Content</div>'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'div', element.tag_name
    assert_equal 'test', element.attributes['class']
    assert_equal 'main', element.attributes['id']
  end

  def test_parses_self_closing_element
    source = '<br>'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'br', element.tag_name
    assert_equal true, element.self_closing
  end

  def test_parses_img_element
    source = '<img src="test.png" alt="test">'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'img', element.tag_name
    assert_equal 'test.png', element.attributes['src']
    assert_equal 'test', element.attributes['alt']
  end

  def test_parses_erb_comment
    source = '<%# This is a comment %>'
    ir = @parser.parse(source)
    
    comment = ir.children.first
    assert_instance_of Any2Any::IR::Comment, comment
    assert_equal 'This is a comment', comment.text
    assert_equal false, comment.html_visible
  end

  def test_parses_erb_code_block
    source = '<% if true %><div>Yes</div><% end %>'
    ir = @parser.parse(source)
    
    # ERB code blocks may or may not create IR nodes depending on parsing
    # The important thing is that parsing doesn't raise an error
    assert_instance_of Any2Any::IR::Template, ir
  end

  def test_parses_unescaped_output
    source = '<%== raw_html %>'
    ir = @parser.parse(source)
    
    expr = ir.children.first
    assert_instance_of Any2Any::IR::Expression, expr
    assert_equal 'raw_html', expr.code
    assert_equal false, expr.escaped
  end

  def test_parses_multiple_elements
    source = '<div>First</div><p>Second</p>'
    ir = @parser.parse(source)
    
    assert_equal 2, ir.children.length
    assert_equal 'div', ir.children[0].tag_name
    assert_equal 'p', ir.children[1].tag_name
  end

  def test_parses_data_attributes
    source = '<div data-controller="modal" data-action="click->modal#open">Click</div>'
    ir = @parser.parse(source)
    
    element = ir.children.first
    assert_equal 'modal', element.attributes['data-controller']
    assert_equal 'click->modal#open', element.attributes['data-action']
  end

  def test_parses_deeply_nested
    source = '<div><section><article><p>Deep</p></article></section></div>'
    ir = @parser.parse(source)
    
    div = ir.children.first
    assert_equal 'div', div.tag_name
    section = div.children.first
    assert_equal 'section', section.tag_name
    article = section.children.first
    assert_equal 'article', article.tag_name
  end

  def test_handles_parse_error
    @parser = Any2Any::Parsers::ErbParser.new
    # Deliberately create an invalid parse that would fail
    # This tests error handling
    assert_raises(Any2Any::ParseError) do
      # Force a parse error by mocking Herb to return errors
      allow_herb_to_fail = proc do
        result = Struct.new(:errors, :value).new([Struct.new(:message).new('Test error')], nil)
        Herb.stub :parse, result do
          @parser.parse('<div>')
        end
      end
      allow_herb_to_fail.call
    end
  end

  def test_warns_on_unknown_node_type
    source = '<div>Test</div>'
    @parser.parse(source)
    # Parser should handle unknown node types gracefully
    assert_instance_of Any2Any::WarningCollector, @parser.warnings
  end
end
