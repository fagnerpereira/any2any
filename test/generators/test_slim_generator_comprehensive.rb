# frozen_string_literal: true

require 'test_helper'

class TestSlimGeneratorComprehensive < Minitest::Test
  def setup
    @generator = Any2Any::Generators::SlimGenerator.new
  end

  def test_generates_element_with_multiple_attributes
    element = Any2Any::IR::Element.new(
      tag_name: 'input',
      attributes: {'type' => 'text', 'name' => 'email', 'placeholder' => 'Email'},
      children: []
    )
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert output.include?('input')
    assert output.include?('type="text"')
    assert output.include?('name="email"')
    assert output.include?('placeholder="Email"')
  end

  def test_generates_deeply_nested
    p_tag = Any2Any::IR::Element.new(tag_name: 'p', attributes: {}, children: [])
    article = Any2Any::IR::Element.new(tag_name: 'article', attributes: {}, children: [p_tag])
    section = Any2Any::IR::Element.new(tag_name: 'section', attributes: {}, children: [article])
    div = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [section])
    ir = Any2Any::IR::Template.new(children: [div])
    
    output = @generator.generate(ir)
    assert output.include?('div')
    assert output.include?('section')
    assert output.include?('article')
    assert output.include?('p')
  end

  def test_generates_conditional
    cond = Any2Any::IR::Conditional.new(
      condition: 'user.present?',
      true_branch: [Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])],
      false_branch: []
    )
    ir = Any2Any::IR::Template.new(children: [cond])
    
    output = @generator.generate(ir)
    assert output.include?('- if user.present?')
    assert output.include?('div')
  end

  def test_generates_conditional_with_else
    cond = Any2Any::IR::Conditional.new(
      condition: 'admin?',
      true_branch: [Any2Any::IR::StaticContent.new(text: 'Admin')],
      false_branch: [Any2Any::IR::StaticContent.new(text: 'User')]
    )
    ir = Any2Any::IR::Template.new(children: [cond])
    
    output = @generator.generate(ir)
    assert output.include?('- if admin?')
    assert output.include?('- else')
  end

  def test_generates_loop
    loop_node = Any2Any::IR::Loop.new(
      collection: '@items',
      variable: 'item',
      body: [Any2Any::IR::Expression.new(code: 'item.name', escaped: true)]
    )
    ir = Any2Any::IR::Template.new(children: [loop_node])
    
    output = @generator.generate(ir)
    assert output.include?('- @items.each do |item|')
    assert output.include?('= item.name')
  end

  def test_generates_block_with_children
    block = Any2Any::IR::Block.new(
      code: 'if true',
      children: [Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])]
    )
    ir = Any2Any::IR::Template.new(children: [block])
    
    output = @generator.generate(ir)
    assert output.include?('- if true')
    assert output.include?('div')
  end

  def test_generates_multiple_children
    children = [
      Any2Any::IR::Element.new(tag_name: 'h1', attributes: {}, children: []),
      Any2Any::IR::Element.new(tag_name: 'p', attributes: {}, children: []),
      Any2Any::IR::Element.new(tag_name: 'footer', attributes: {}, children: [])
    ]
    ir = Any2Any::IR::Template.new(children: children)
    
    output = @generator.generate(ir)
    assert output.include?('h1')
    assert output.include?('p')
    assert output.include?('footer')
  end

  def test_escapes_quotes_in_attributes
    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: {'data-value' => 'He said "hello"'},
      children: []
    )
    ir = Any2Any::IR::Template.new(children: [element])
    
    output = @generator.generate(ir)
    assert output.include?('div')
  end

  def test_handles_empty_template
    ir = Any2Any::IR::Template.new(children: [])
    output = @generator.generate(ir)
    assert_equal '', output
  end

  def test_generates_html_comment
    comment = Any2Any::IR::Comment.new(text: 'TODO: Fix this', html_visible: true)
    ir = Any2Any::IR::Template.new(children: [comment])
    
    output = @generator.generate(ir)
    assert output.include?('/')
    assert output.include?('TODO: Fix this')
  end

  def test_generates_slim_comment
    comment = Any2Any::IR::Comment.new(text: 'Internal note', html_visible: false)
    ir = Any2Any::IR::Template.new(children: [comment])
    
    output = @generator.generate(ir)
    assert output.include?('-')
    assert output.include?('#')
  end

  def test_raises_on_invalid_ir
    assert_raises(ArgumentError) do
      @generator.generate(Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: []))
    end
  end
end
