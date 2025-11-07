# frozen_string_literal: true

require 'test_helper'

class TestPhlexGenerator < Minitest::Test
  def setup
    @generator = Any2Any::Generators::PhlexGenerator.new
  end

  def test_generates_simple_element
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(tag_name: 'div')
      ]
    )

    output = @generator.generate(ir)

    assert_match(/class ViewComponent < Phlex::HTML/, output)
    assert_match(/def view_template/, output)
    assert_match(/div/, output)
  end

  def test_generates_nested_elements
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(
          tag_name: 'div',
          children: [
            Any2Any::IR::Element.new(tag_name: 'p')
          ]
        )
      ]
    )

    output = @generator.generate(ir)

    assert_match(/div do/, output)
    assert_match(/p/, output)
    assert_match(/end/, output)
  end

  def test_generates_element_with_attributes
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(
          tag_name: 'div',
          attributes: { 'class' => 'container', 'id' => 'main' }
        )
      ]
    )

    output = @generator.generate(ir)

    assert_match(/div\(/, output)
    assert_match(/class: "container"/, output)
    assert_match(/id: "main"/, output)
  end

  def test_generates_expression
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Expression.new(code: '@name', escaped: true)
      ]
    )

    output = @generator.generate(ir)

    assert_match(/plain @name/, output)
  end

  def test_generates_unescaped_expression
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Expression.new(code: '@html_content', escaped: false)
      ]
    )

    output = @generator.generate(ir)

    assert_match(/raw @html_content/, output)
  end

  def test_generates_static_content
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: 'Hello World')
      ]
    )

    output = @generator.generate(ir)

    assert_match(/plain "Hello World"/, output)
  end

  def test_generates_comment
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Comment.new(text: 'This is a comment', html_visible: true)
      ]
    )

    output = @generator.generate(ir)

    assert_match(/comment/, output)
  end

  def test_generates_conditional
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Conditional.new(
          condition: '@show',
          true_branch: [
            Any2Any::IR::Element.new(tag_name: 'p')
          ],
          false_branch: []
        )
      ]
    )

    output = @generator.generate(ir)

    assert_match(/if @show/, output)
    assert_match(/p/, output)
    assert_match(/end/, output)
  end

  def test_generates_loop
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Loop.new(
          collection: '@items',
          variable: 'item',
          body: [
            Any2Any::IR::Element.new(tag_name: 'li')
          ]
        )
      ]
    )

    output = @generator.generate(ir)

    assert_match(/@items\.each do \|item\|/, output)
    assert_match(/li/, output)
    assert_match(/end/, output)
  end

  def test_generates_self_closing_element
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(
          tag_name: 'br',
          self_closing: true
        )
      ]
    )

    output = @generator.generate(ir)

    assert_match(/br/, output)
    refute_match(/br do/, output)
  end
end
