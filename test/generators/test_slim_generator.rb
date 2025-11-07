# frozen_string_literal: true

require 'test_helper'

class TestSlimGenerator < Minitest::Test
  def setup
    @generator = Any2Any::Generators::SlimGenerator.new
  end

  def test_generates_simple_element
    element = Any2Any::IR::Element.new(tag_name: 'div')
    template = Any2Any::IR::Template.new(children: [element])
    output = @generator.generate(template)

    assert_equal 'div', output
  end

  def test_generates_nested_elements
    p_tag = Any2Any::IR::Element.new(tag_name: 'p')
    div = Any2Any::IR::Element.new(tag_name: 'div', children: [p_tag])
    template = Any2Any::IR::Template.new(children: [div])
    output = @generator.generate(template)

    assert_includes output, 'div'
    assert_includes output, 'p'
  end

  def test_generates_expression
    expr = Any2Any::IR::Expression.new(code: '@name')
    template = Any2Any::IR::Template.new(children: [expr])
    output = @generator.generate(template)

    assert_equal '= @name', output
  end

  def test_generates_static_content
    content = Any2Any::IR::StaticContent.new(text: 'Hello')
    template = Any2Any::IR::Template.new(children: [content])
    output = @generator.generate(template)

    assert_includes output, 'Hello'
  end

  def test_generates_block
    block = Any2Any::IR::Block.new(code: 'x = 1')
    template = Any2Any::IR::Template.new(children: [block])
    output = @generator.generate(template)

    assert_includes output, '- x = 1'
  end

  def test_generates_comment
    comment = Any2Any::IR::Comment.new(text: 'This is a comment', html_visible: false)
    template = Any2Any::IR::Template.new(children: [comment])
    output = @generator.generate(template)

    assert_includes output, '- #'
  end
end
