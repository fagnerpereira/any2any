# frozen_string_literal: true

require 'test_helper'

class TestSlimGenerator < Minitest::Test
  def setup
    @generator = TemplateConverter::Generators::SlimGenerator.new
  end

  def test_generates_simple_element
    element = TemplateConverter::IR::Element.new(tag_name: 'div')
    template = TemplateConverter::IR::Template.new(children: [element])
    output = @generator.generate(template)

    assert_equal 'div', output
  end

  def test_generates_nested_elements
    p_tag = TemplateConverter::IR::Element.new(tag_name: 'p')
    div = TemplateConverter::IR::Element.new(tag_name: 'div', children: [p_tag])
    template = TemplateConverter::IR::Template.new(children: [div])
    output = @generator.generate(template)

    assert_includes output, 'div'
    assert_includes output, 'p'
  end

  def test_generates_expression
    expr = TemplateConverter::IR::Expression.new(code: '@name')
    template = TemplateConverter::IR::Template.new(children: [expr])
    output = @generator.generate(template)

    assert_equal '= @name', output
  end

  def test_generates_static_content
    content = TemplateConverter::IR::StaticContent.new(text: 'Hello')
    template = TemplateConverter::IR::Template.new(children: [content])
    output = @generator.generate(template)

    assert_includes output, 'Hello'
  end

  def test_generates_block
    block = TemplateConverter::IR::Block.new(code: 'x = 1')
    template = TemplateConverter::IR::Template.new(children: [block])
    output = @generator.generate(template)

    assert_includes output, '- x = 1'
  end

  def test_generates_comment
    comment = TemplateConverter::IR::Comment.new(text: 'This is a comment', html_visible: false)
    template = TemplateConverter::IR::Template.new(children: [comment])
    output = @generator.generate(template)

    assert_includes output, '- #'
  end
end
