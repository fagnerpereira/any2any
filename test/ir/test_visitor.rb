# frozen_string_literal: true

require 'test_helper'

class TestVisitor < Minitest::Test
  def test_visitor_can_be_inherited
    visitor_class = Class.new(Any2Any::IR::Visitor)
    visitor = visitor_class.new
    
    assert_instance_of visitor_class, visitor
  end

  def test_visitor_visit_template
    visitor = Any2Any::IR::Visitor.new
    template = Any2Any::IR::Template.new(children: [])
    
    # Should not raise error
    visitor.visit(template)
  end

  def test_visitor_visit_element
    visitor = Any2Any::IR::Visitor.new
    element = Any2Any::IR::Element.new(tag_name: 'div', attributes: {}, children: [])
    
    visitor.visit(element)
  end

  def test_visitor_visit_expression
    visitor = Any2Any::IR::Visitor.new
    expr = Any2Any::IR::Expression.new(code: 'test', escaped: true)
    
    visitor.visit(expr)
  end

  def test_visitor_visit_block
    visitor = Any2Any::IR::Visitor.new
    block = Any2Any::IR::Block.new(code: 'test')
    
    visitor.visit(block)
  end

  def test_visitor_visit_static_content
    visitor = Any2Any::IR::Visitor.new
    content = Any2Any::IR::StaticContent.new(text: 'test')
    
    visitor.visit(content)
  end

  def test_visitor_visit_comment
    visitor = Any2Any::IR::Visitor.new
    comment = Any2Any::IR::Comment.new(text: 'test', html_visible: true)
    
    visitor.visit(comment)
  end

  def test_visitor_visit_conditional
    visitor = Any2Any::IR::Visitor.new
    cond = Any2Any::IR::Conditional.new(condition: 'test', true_branch: [], false_branch: [])
    
    visitor.visit(cond)
  end

  def test_visitor_visit_loop
    visitor = Any2Any::IR::Visitor.new
    loop_node = Any2Any::IR::Loop.new(collection: '@items', variable: 'item', body: [])
    
    visitor.visit(loop_node)
  end
end
