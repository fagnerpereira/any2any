# frozen_string_literal: true

require 'test_helper'

class TestAttributes < Minitest::Test
  def test_erb_with_class_attributes_to_slim
    erb_source = '<div class="container mx-auto"><h1 class="text-xl font-bold">Title</h1></div>'
    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('div class="container mx-auto"')
    assert output.include?('h1 class="text-xl font-bold"')
    assert output.include?('Title')
  end

  def test_erb_with_class_attributes_to_haml
    erb_source = '<div class="container mx-auto"><h1 class="text-xl font-bold">Title</h1></div>'
    result = Any2Any.convert(erb_source, from: :erb, to: :haml)
    output = result[:output]

    assert output.include?('%div{class: "container mx-auto"}')
    assert output.include?('%h1{class: "text-xl font-bold"}')
    assert output.include?('Title')
  end

  def test_erb_with_multiple_attributes_to_slim
    erb_source = '<input type="text" name="email" class="form-input" placeholder="Enter email">'
    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('input')
    assert output.include?('type="text"')
    assert output.include?('name="email"')
    assert output.include?('class="form-input"')
    assert output.include?('placeholder="Enter email"')
  end

  def test_erb_with_multiple_attributes_to_haml
    erb_source = '<input type="text" name="email" class="form-input" placeholder="Enter email">'
    result = Any2Any.convert(erb_source, from: :erb, to: :haml)
    output = result[:output]

    assert output.include?('%input')
    assert output.include?('type: "text"')
    assert output.include?('name: "email"')
    assert output.include?('class: "form-input"')
    assert output.include?('placeholder: "Enter email"')
  end

  def test_erb_with_id_and_class_to_slim
    erb_source = '<div id="main" class="wrapper container">Content</div>'
    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('div')
    assert output.include?('id="main"')
    assert output.include?('class="wrapper container"')
    assert output.include?('Content')
  end

  def test_erb_with_id_and_class_to_haml
    erb_source = '<div id="main" class="wrapper container">Content</div>'
    result = Any2Any.convert(erb_source, from: :erb, to: :haml)
    output = result[:output]

    assert output.include?('%div')
    assert output.include?('id: "main"')
    assert output.include?('class: "wrapper container"')
    assert output.include?('Content')
  end

  def test_slim_with_attributes_to_erb
    slim_source = 'div class="container" id="main"\n  p class="text" Hello'
    result = Any2Any.convert(slim_source, from: :slim, to: :erb)
    output = result[:output]

    assert output.include?('<div')
    assert output.include?('class="container"')
    assert output.include?('id="main"')
    assert output.include?('<p')
    assert output.include?('class="text"')
  end

  def test_haml_with_attributes_to_erb
    haml_source = '%div{class: "container", id: "main"}\n  %p{class: "text"} Hello'
    result = Any2Any.convert(haml_source, from: :haml, to: :erb)
    output = result[:output]

    assert output.include?('<div')
    assert output.include?('class="container"')
    assert output.include?('id="main"')
    assert output.include?('<p')
    assert output.include?('class="text"')
  end

  def test_erb_with_data_attributes_to_slim
    erb_source = '<button data-action="click" data-controller="modal">Open</button>'
    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('button')
    assert output.include?('data-action="click"')
    assert output.include?('data-controller="modal"')
  end

  def test_erb_with_data_attributes_to_haml
    erb_source = '<button data-action="click" data-controller="modal">Open</button>'
    result = Any2Any.convert(erb_source, from: :erb, to: :haml)
    output = result[:output]

    assert output.include?('%button')
    assert output.include?('data-action: "click"')
    assert output.include?('data-controller: "modal"')
  end

  def test_complex_erb_to_slim_preserves_all_attributes
    erb_source = <<~ERB
      <div class="md:w-2/3 w-full">
        <h1 class="font-bold text-4xl">Editing book</h1>
      </div>
    ERB

    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    assert output.include?('div class="md:w-2/3 w-full"')
    assert output.include?('h1 class="font-bold text-4xl"')
    assert output.include?('Editing book')
  end

  def test_complex_erb_to_haml_preserves_all_attributes
    erb_source = <<~ERB
      <div class="md:w-2/3 w-full">
        <h1 class="font-bold text-4xl">Editing book</h1>
      </div>
    ERB

    result = Any2Any.convert(erb_source, from: :erb, to: :haml)
    output = result[:output]

    assert output.include?('%div{class: "md:w-2/3 w-full"}')
    assert output.include?('%h1{class: "font-bold text-4xl"}')
    assert output.include?('Editing book')
  end

  def test_erb_with_inline_text_to_slim
    erb_source = '<p class="text">Hello World</p>'
    result = Any2Any.convert(erb_source, from: :erb, to: :slim)
    output = result[:output]

    # Should be inline: p class="text" Hello World
    assert output.include?('p class="text" Hello World')
  end

  def test_erb_with_inline_text_to_haml
    erb_source = '<p class="text">Hello World</p>'
    result = Any2Any.convert(erb_source, from: :erb, to: :haml)
    output = result[:output]

    # Should be inline: %p{class: "text"} Hello World
    assert output.include?('%p{class: "text"} Hello World')
  end

  def test_erb_to_phlex_with_attributes
    erb_source = '<div class="container"><p class="text">Hello</p></div>'
    result = Any2Any.convert(erb_source, from: :erb, to: :phlex)
    output = result[:output]

    assert output.include?('Phlex::HTML')
    assert output.include?('class: "container"')
    assert output.include?('class: "text"')
  end

  def test_slim_to_haml_preserves_attributes
    slim_source = 'div class="container mx-auto"\n  h1 class="title" Welcome'
    result = Any2Any.convert(slim_source, from: :slim, to: :haml)
    output = result[:output]

    assert output.include?('%div{class: "container mx-auto"}')
    assert output.include?('%h1{class: "title"}')
  end

  def test_haml_to_slim_preserves_attributes
    haml_source = '%div{class: "container mx-auto"}\n  %h1{class: "title"} Welcome'
    result = Any2Any.convert(haml_source, from: :haml, to: :slim)
    output = result[:output]

    assert output.include?('div class="container mx-auto"')
    assert output.include?('h1 class="title"')
  end
end
