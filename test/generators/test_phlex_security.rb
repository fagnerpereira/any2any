require 'minitest/autorun'
require_relative '../test_helper'
require 'any2any/ir/static_content'
require 'any2any/ir/template'
require 'any2any/generators/phlex_generator'

class TestPhlexSecurity < Minitest::Test
  def test_static_content_injection_escaped
    # Create a StaticContent node with Ruby interpolation
    static_content = Any2Any::IR::StaticContent.new(text: 'Hello #{system("echo injected")} World')

    # Create a template containing this node
    template = Any2Any::IR::Template.new(children: [static_content])

    # Generate Phlex code
    generator = Any2Any::Generators::PhlexGenerator.new
    output = generator.generate(template)

    # Assert that interpolation is escaped
    assert_includes output, '\\#{', "Interpolation start \#{ was not escaped"

    # Verify exact output string part
    expected_part = 'plain "Hello \#{system(\"echo injected\")} World"'
    assert_includes output, expected_part
  end

  def test_instance_variable_interpolation_escaped
    # Test escaping of #@var
    static_content = Any2Any::IR::StaticContent.new(text: 'Hello #@user')
    template = Any2Any::IR::Template.new(children: [static_content])
    generator = Any2Any::Generators::PhlexGenerator.new
    output = generator.generate(template)

    assert_includes output, '\\#@user'
  end

  def test_global_variable_interpolation_escaped
    # Test escaping of #$global
    static_content = Any2Any::IR::StaticContent.new(text: 'Hello #$PROGRAM_NAME')
    template = Any2Any::IR::Template.new(children: [static_content])
    generator = Any2Any::Generators::PhlexGenerator.new
    output = generator.generate(template)

    assert_includes output, '\\#$PROGRAM_NAME'
  end
end
