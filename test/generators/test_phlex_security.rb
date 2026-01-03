require "test_helper"

class TestPhlexSecurity < Minitest::Test
  def setup
    @generator = Any2Any::Generators::PhlexGenerator.new
  end

  def test_escapes_interpolation_in_attributes
    # If the user input contains #{...}, it should be escaped so it's not evaluated by Ruby
    # when the Phlex component is executed.

    # Simulate a node with an attribute containing interpolation syntax
    # e.g. <div data-val="#{system('rm -rf /')}"></div>
    element = Any2Any::IR::Element.new(
      tag_name: "div",
      attributes: { "data-val" => "\#{system('rm -rf /')}" }
    )

    generated_code = @generator.generate(Any2Any::IR::Template.new(children: [element]))

    # We expect the output to have escaped the interpolation
    # Bad output: div(data-val: "#{system('rm -rf /')}")
    # Good output: div(data-val: "\#{system('rm -rf /')}")

    # NOTE: In Ruby string literal for the expected output:
    # We want the generated code to contain: data-val: "\#{...}"
    # So we need to check for backslash before hash.

    assert_includes generated_code, '\\#{'
    refute_includes generated_code, ' #{'
  end

  def test_escapes_backslashes_in_attributes
    # If input is "\"", it should be escaped to "\\" in the string literal

    element = Any2Any::IR::Element.new(
      tag_name: "div",
      attributes: { "data-val" => "\\" }
    )

    generated_code = @generator.generate(Any2Any::IR::Template.new(children: [element]))

    # Input: \
    # Desired Ruby code: div(data-val: "\\")
    # Inside the string literal it should be "\\" (two backslashes)

    assert_includes generated_code, '\\\\'
  end

  def test_escapes_interpolation_in_static_content
    content = Any2Any::IR::StaticContent.new(text: "\#{system('ls')}")

    generated_code = @generator.generate(Any2Any::IR::Template.new(children: [content]))

    # plain "\#{system('ls')}"
    assert_includes generated_code, '\\#{'
  end
end
