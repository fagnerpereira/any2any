# frozen_string_literal: true

require 'test_helper'

class TestPhlexParser < Minitest::Test
  def setup
    @parser = TemplateConverter::Parsers::PhlexParser.new
  end

  def test_parses_simple_element
    source = File.read('test/fixtures/phlex/simple_div.rb')
    ir = @parser.parse(source)

    assert_instance_of TemplateConverter::IR::Template, ir
    assert_equal 1, ir.children.length

    div = ir.children.first
    assert_instance_of TemplateConverter::IR::Element, div
    assert_equal 'div', div.tag_name
  end

  def test_parses_nested_elements
    source = File.read('test/fixtures/phlex/nested_slim.rb')
    ir = @parser.parse(source)

    assert_instance_of TemplateConverter::IR::Template, ir
    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 1, div.children.length

    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name
  end

  def test_parses_element_with_attributes
    source = File.read('test/fixtures/phlex/attributes.rb')
    ir = @parser.parse(source)

    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 'container', div.attributes['class']

    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name
    assert_equal 'intro', p_tag.attributes['id']
    assert_equal 'text', p_tag.attributes['class']
  end

  def test_parses_expression
    source = File.read('test/fixtures/phlex/with_expression_slim.rb')
    ir = @parser.parse(source)

    div = ir.children.first
    p_tag = div.children.first

    # The expression should be in the p tag children
    assert p_tag.children.any? { |c| c.is_a?(TemplateConverter::IR::Expression) }
  end

  def test_parses_conditional
    source = File.read('test/fixtures/phlex/with_conditional.rb')
    ir = @parser.parse(source)

    div = ir.children.first
    conditional = div.children.first

    assert_instance_of TemplateConverter::IR::Conditional, conditional
    assert_equal '@show', conditional.condition
    assert conditional.true_branch.any?
    assert conditional.false_branch.any?
  end

  def test_parses_loop
    source = File.read('test/fixtures/phlex/with_loop.rb')
    ir = @parser.parse(source)

    ul = ir.children.first
    loop_node = ul.children.first

    assert_instance_of TemplateConverter::IR::Loop, loop_node
    assert_equal '@items', loop_node.collection
    assert_equal 'item', loop_node.variable
    assert loop_node.body.any?
  end

  def test_raises_error_without_view_template
    source = <<~RUBY
      class NoTemplateComponent < Phlex::HTML
        def some_other_method
          div
        end
      end
    RUBY

    error = assert_raises(TemplateConverter::ParseError) do
      @parser.parse(source)
    end

    assert_match(/view_template/, error.message)
  end
end
