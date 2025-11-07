# frozen_string_literal: true

require 'test_helper'

class TestErbGenerator < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_generates_simple_element
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert_equal '<div></div>', output
  end

  def test_generates_element_with_attributes
    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: {'class' => 'container', 'id' => 'main'},
      children: []
    )
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert output.include?('<div')
    assert output.include?('class="container"')
    assert output.include?('id="main"')
  end

  def test_generates_nested_elements
    inner = Any2Any::IR::Element.new(tag_name: 'p', attributes: {}, children: [])
    outer = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [inner])
    ir = Any2Any::IR::Template.new(children: [outer])
    
    output = @generator.generate(ir)
    assert output.include?('<div>')
    assert output.include?('<p></p>')
    assert output.include?('</div>')
  end

  def test_generates_self_closing_element
    element = Any2Any::IR::Element.new(tag_name: 'br', attributes: {}, children: [], self_closing: true)
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert_equal '<br>', output
  end

  def test_generates_static_content
    content = Any2Any::IR::StaticContent.new(text: 'Hello World')
    ir = Any2Any::IR::Template.new(children: [content])
    
    output = @generator.generate(ir)
    assert_equal 'Hello World', output
  end

  def test_generates_expression
    expr = Any2Any::IR::Expression.new(code: '@user.name', escaped: true)
    ir = Any2Any::IR::Template.new(children: [expr])
    
    output = @generator.generate(ir)
    assert_equal '<%= @user.name %>', output
  end

  def test_generates_unescaped_expression
    expr = Any2Any::IR::Expression.new(code: '@html_content', escaped: false)
    ir = Any2Any::IR::Template.new(children: [expr])
    
    output = @generator.generate(ir)
    assert_equal '<%== @html_content %>', output
  end

  def test_generates_block
    block = Any2Any::IR::Block.new(code: 'items.each do |item|')
    ir = Any2Any::IR::Template.new(children: [block])
    
    output = @generator.generate(ir)
    assert_equal '<% items.each do |item| %>', output
  end

  def test_generates_conditional
    cond = Any2Any::IR::Conditional.new(
      condition: 'user.present?',
      true_branch: [Any2Any::IR::StaticContent.new(text: 'Yes')],
      false_branch: []
    )
    ir = Any2Any::IR::Template.new(children: [cond])
    
    output = @generator.generate(ir)
    assert output.include?('<% if user.present? %>')
    assert output.include?('Yes')
    assert output.include?('<% end %>')
  end

  def test_generates_conditional_with_else
    cond = Any2Any::IR::Conditional.new(
      condition: 'user.present?',
      true_branch: [Any2Any::IR::StaticContent.new(text: 'Yes')],
      false_branch: [Any2Any::IR::StaticContent.new(text: 'No')]
    )
    ir = Any2Any::IR::Template.new(children: [cond])
    
    output = @generator.generate(ir)
    assert output.include?('<% if user.present? %>')
    assert output.include?('Yes')
    assert output.include?('<% else %>')
    assert output.include?('No')
    assert output.include?('<% end %>')
  end

  def test_generates_loop
    loop_node = Any2Any::IR::Loop.new(
      collection: '@users',
      variable: 'user',
      body: [Any2Any::IR::Expression.new(code: 'user.name', escaped: true)]
    )
    ir = Any2Any::IR::Template.new(children: [loop_node])
    
    output = @generator.generate(ir)
    assert output.include?('<% @users.each do |user| %>')
    assert output.include?('<%= user.name %>')
    assert output.include?('<% end %>')
  end

  def test_generates_comment
    comment = Any2Any::IR::Comment.new(text: 'This is a comment', html_visible: true)
    ir = Any2Any::IR::Template.new(children: [comment])
    
    output = @generator.generate(ir)
    assert_equal '<!-- This is a comment -->', output
  end

  def test_generates_erb_comment
    comment = Any2Any::IR::Comment.new(text: 'This is hidden', html_visible: false)
    ir = Any2Any::IR::Template.new(children: [comment])
    
    output = @generator.generate(ir)
    assert_equal '<%# This is hidden %>', output
  end

  def test_escapes_html_in_attributes
    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: {'data-value' => '<script>alert("xss")</script>'},
      children: []
    )
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert output.include?('&lt;script&gt;')
  end

  def test_generates_complex_nested_structure
    inner_content = Any2Any::IR::StaticContent.new(text: 'Content')
    inner_elem = Any2Any::IR::Element.new(tag_name: 'p', attributes: {'class' => 'text'}, children: [inner_content])
    outer_elem = Any2Any::IR::Element.new(tag_name: 'div', attributes: {'id' => 'main'}, children: [inner_elem])
    ir = Any2Any::IR::Template.new(children: [outer_elem])
    
    output = @generator.generate(ir)
    assert output.include?('<div id="main">')
    assert output.include?('<p class="text">')
    assert output.include?('Content')
    assert output.include?('</p>')
    assert output.include?('</div>')
  end
end
