# frozen_string_literal: true

require 'test_helper'

class TestHamlGenerator < Minitest::Test
  def setup
    @generator = Any2Any::Generators::HamlGenerator.new
  end

  def test_generates_simple_element
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert_equal '%div', output
  end

  def test_generates_element_with_attributes
    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: {'class' => 'container', 'id' => 'main'},
      children: []
    )
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert output.include?('%div{')
    assert output.include?('class: "container"')
    assert output.include?('id: "main"')
  end

  def test_generates_nested_elements
    inner = Any2Any::IR::Element.new(tag_name: 'p', attributes: {}, children: [])
    outer = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [inner])
    ir = Any2Any::IR::Template.new(children: [outer])
    
    output = @generator.generate(ir)
    assert output.include?('%div')
    assert output.include?('%p')
  end

  def test_generates_inline_text
    content = Any2Any::IR::StaticContent.new(text: 'Hello World')
    element = Any2Any::IR::Element.new(tag_name: 'p', attributes: {}, children: [content])
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert output.include?('%p Hello World')
  end

  def test_generates_expression
    expr = Any2Any::IR::Expression.new(code: '@user.name', escaped: true)
    ir = Any2Any::IR::Template.new(children: [expr])
    
    output = @generator.generate(ir)
    assert_equal '= @user.name', output
  end

  def test_generates_unescaped_expression
    expr = Any2Any::IR::Expression.new(code: '@html', escaped: false)
    ir = Any2Any::IR::Template.new(children: [expr])
    
    output = @generator.generate(ir)
    assert_equal '!= @html', output
  end

  def test_generates_block
    block = Any2Any::IR::Block.new(code: 'if true')
    ir = Any2Any::IR::Template.new(children: [block])
    
    output = @generator.generate(ir)
    assert_equal '- if true', output
  end

  def test_generates_comment
    comment = Any2Any::IR::Comment.new(text: 'Comment', html_visible: true)
    ir = Any2Any::IR::Template.new(children: [comment])
    
    output = @generator.generate(ir)
    assert_equal '/ Comment', output
  end

  def test_generates_silent_comment
    comment = Any2Any::IR::Comment.new(text: 'Hidden', html_visible: false)
    ir = Any2Any::IR::Template.new(children: [comment])
    
    output = @generator.generate(ir)
    assert_equal '-# Hidden', output
  end

  def test_generates_self_closing
    element = Any2Any::IR::Element.new(tag_name: 'br', attributes: {}, children: [], self_closing: true)
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert_equal '%br', output
  end

  def test_escapes_html_in_attributes
    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: {'data-value' => '<script>'},
      children: []
    )
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert output.include?('&lt;script&gt;')
  end
end
