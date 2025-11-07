# frozen_string_literal: true

require 'test_helper'

class TestIRNodes < Minitest::Test
  def test_template_creation
    template = Any2Any::IR::Template.new
    assert_instance_of Any2Any::IR::Template, template
    assert_empty template.children
  end

  def test_template_with_children
    element = Any2Any::IR::Element.new(tag_name: 'div')
    template = Any2Any::IR::Template.new(children: [element])
    assert_equal 1, template.children.length
    assert_equal element, template.children.first
  end

  def test_element_creation
    element = Any2Any::IR::Element.new(tag_name: 'div')
    assert_equal 'div', element.tag_name
    assert_empty element.attributes
    assert_empty element.children
    assert_equal false, element.self_closing
  end

  def test_element_with_attributes
    element = Any2Any::IR::Element.new(
      tag_name: 'div',
      attributes: { 'class' => 'container', 'id' => 'main' }
    )
    assert_equal 'container', element.attributes['class']
    assert_equal 'main', element.attributes['id']
  end

  def test_self_closing_element
    br = Any2Any::IR::Element.new(tag_name: 'br', self_closing: true)
    assert_equal true, br.self_closing
  end

  def test_expression_creation
    expr = Any2Any::IR::Expression.new(code: '@name')
    assert_equal '@name', expr.code
    assert_equal true, expr.escaped
  end

  def test_expression_unescaped
    expr = Any2Any::IR::Expression.new(code: '@html', escaped: false)
    assert_equal false, expr.escaped
  end

  def test_block_creation
    block = Any2Any::IR::Block.new(code: 'x = 1')
    assert_equal 'x = 1', block.code
  end

  def test_conditional_creation
    cond = Any2Any::IR::Conditional.new(condition: '@user.present?')
    assert_equal '@user.present?', cond.condition
  end

  def test_conditional_with_branches
    true_br = [Any2Any::IR::StaticContent.new(text: 'User exists')]
    false_br = [Any2Any::IR::StaticContent.new(text: 'No user')]

    cond = Any2Any::IR::Conditional.new(
      condition: '@user.present?',
      true_branch: true_br,
      false_branch: false_br
    )

    assert_equal 1, cond.true_branch.length
    assert_equal 1, cond.false_branch.length
  end

  def test_loop_creation
    loop_node = Any2Any::IR::Loop.new(
      collection: '@users',
      variable: 'user'
    )
    assert_equal '@users', loop_node.collection
    assert_equal 'user', loop_node.variable
  end

  def test_static_content_creation
    content = Any2Any::IR::StaticContent.new(text: 'Hello World')
    assert_equal 'Hello World', content.text
  end

  def test_comment_creation
    comment = Any2Any::IR::Comment.new(text: 'This is a comment')
    assert_equal 'This is a comment', comment.text
    assert_equal false, comment.html_visible
  end

  def test_html_visible_comment
    comment = Any2Any::IR::Comment.new(text: 'HTML comment', html_visible: true)
    assert_equal true, comment.html_visible
  end

  def test_node_equality
    elem1 = Any2Any::IR::Element.new(tag_name: 'div')
    elem2 = Any2Any::IR::Element.new(tag_name: 'div')
    elem3 = Any2Any::IR::Element.new(tag_name: 'p')

    assert_equal elem1, elem2
    refute_equal elem1, elem3
  end
end
