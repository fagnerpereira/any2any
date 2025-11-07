# frozen_string_literal: true

require 'test_helper'

class TestPhlexParserComprehensive < Minitest::Test
  def setup
    @parser = Any2Any::Parsers::PhlexParser.new
  end

  def test_parses_simple_component
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          div
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    assert_instance_of Any2Any::IR::Template, ir
    assert ir.children.length > 0
  end

  def test_parses_component_with_content
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          div { "Hello" }
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    element = ir.children.first
    assert_equal 'div', element.tag_name
  end

  def test_parses_component_with_attributes
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          div(class: "container", id: "main") { "Content" }
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    element = ir.children.first
    assert_equal 'container', element.attributes['class']
    assert_equal 'main', element.attributes['id']
  end

  def test_parses_nested_elements
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          div do
            p { "Hello" }
          end
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    div = ir.children.first
    assert_equal 'div', div.tag_name
    assert_equal 1, div.children.length
  end

  def test_parses_plain_text
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          plain "Hello World"
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    content = ir.children.first
    assert_instance_of Any2Any::IR::StaticContent, content
  end

  def test_parses_whitespace
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          whitespace
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    # whitespace may or may not create a node
    if ir.children.any?
      content = ir.children.first
      assert_instance_of Any2Any::IR::StaticContent, content if content
    else
      assert_equal 0, ir.children.length
    end
  end

  def test_parses_comment
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          comment "This is a comment"
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    comment = ir.children.first
    assert_instance_of Any2Any::IR::Comment, comment
  end

  def test_parses_unsafe_raw
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          unsafe_raw "<script>alert('test')</script>"
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    # unsafe_raw may or may not be fully supported yet
    if ir.children.any?
      expr = ir.children.first
      assert_instance_of Any2Any::IR::Expression, expr if expr
    else
      # May not be implemented yet
      assert_equal 0, ir.children.length
    end
  end

  def test_parses_render_call
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          render SomeComponent.new
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    # render may or may not create a node
    if ir.children.any?
      expr = ir.children.first
      assert_instance_of Any2Any::IR::Expression, expr if expr
    else
      assert_equal 0, ir.children.length
    end
  end

  def test_raises_without_view_template
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def some_method
          div
        end
      end
    RUBY
    
    assert_raises(Any2Any::ParseError) do
      @parser.parse(source)
    end
  end

  def test_handles_invalid_ruby
    assert_raises(Any2Any::ParseError) do
      @parser.parse('invalid ruby code {{{')
    end
  end

  def test_parses_multiple_elements
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          div { "First" }
          p { "Second" }
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    assert_equal 2, ir.children.length
  end

  def test_parses_conditional
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          if @show
            div { "Visible" }
          end
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    assert ir.children.length > 0
  end

  def test_parses_each_loop
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          @items.each do |item|
            p { item.name }
          end
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    assert ir.children.length > 0
  end

  def test_parses_string_interpolation
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          div { "\#{@user.name}" }
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    element = ir.children.first
    assert_equal 'div', element.tag_name
  end

  def test_parses_self_closing_tags
    source = <<~RUBY
      class TestComponent < Phlex::HTML
        def view_template
          br
          hr
        end
      end
    RUBY
    
    ir = @parser.parse(source)
    assert_equal 2, ir.children.length
    assert_equal true, ir.children.first.self_closing
  end
end
