# frozen_string_literal: true

require_relative '../test_helper'
require 'minitest/autorun'

class TestTemplateInjection < Minitest::Test
  def setup
    @erb_generator = Any2Any::Generators::ErbGenerator.new
    @haml_generator = Any2Any::Generators::HamlGenerator.new
    @slim_generator = Any2Any::Generators::SlimGenerator.new
  end

  def test_erb_injection_in_static_content
    # Injection attempt: <% system("echo HACKED") %>
    text = '<% system("echo HACKED") %>'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @erb_generator.generate(template)

    # We expect `<%` to be escaped to `<%%`
    assert_match(/<%% system\("echo HACKED"\) %>/, output, "ERB tags should be escaped in static content")
    refute_match(/^<% system/, output, "ERB tag should not be at start of line unescaped")
  end

  def test_haml_interpolation_injection
    # Injection attempt: #{system("echo HACKED")}
    text = '#{system("echo HACKED")}'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @haml_generator.generate(template)

    # We expect `#{` to be escaped to `\#{`
    assert_match(/\\#\{system\("echo HACKED"\)\}/, output, "Ruby interpolation should be escaped in HAML static content")
    refute_match(/^#\{/, output, "Interpolation should not be unescaped")
  end

  def test_haml_inline_element_injection
    # Injection attempt in inline element: %div #{system("echo HACKED")}
    text = '#{system("echo HACKED")}'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @haml_generator.generate(template)

    assert_match(/%div \\#\{system\("echo HACKED"\)\}/, output, "Ruby interpolation should be escaped in HAML inline element")
  end

  def test_slim_interpolation_injection
    # Injection attempt: #{system("echo HACKED")}
    text = '#{system("echo HACKED")}'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output = @slim_generator.generate(template)

    # We expect `#{` to be escaped to `\#{`
    assert_match(/\| \\#\{system\("echo HACKED"\)\}/, output, "Ruby interpolation should be escaped in Slim static content")
  end

  def test_slim_inline_element_injection
    # Injection attempt in inline element: div #{system("echo HACKED")}
    text = '#{system("echo HACKED")}'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    element = Any2Any::IR::Element.new(tag_name: 'div', children: [static_content])
    template = Any2Any::IR::Template.new(children: [element])

    output = @slim_generator.generate(template)

    assert_match(/div \\#\{system\("echo HACKED"\)\}/, output, "Ruby interpolation should be escaped in Slim inline element")
  end

  def test_backslash_handling
    # Ensure backslashes are escaped before interpolation check
    # Input: \#{foo} -> If we just escape #{ -> \#{foo} -> HAML sees start escape -> #{foo} (interpolated!)
    # So input `\#{foo}` must become `\\#{foo}`
    text = '\#{system("echo HACKED")}'
    static_content = Any2Any::IR::StaticContent.new(text: text)
    template = Any2Any::IR::Template.new(children: [static_content])

    output_haml = @haml_generator.generate(template)
    # HAML: Input `\#{...}` should become `\\#{...}` so that HAML sees `\#{...}` which prints `#{...}` (literal)
    # Wait, if input is `\#{...}`, it means the user WANTS literal `#{...}`?
    # No, static content text is literal text.
    # If text is `#{foo}`, output should be `\#{foo}`.
    # If text is `\#{foo}`, output should be `\\#{foo}`.

    assert_match(/\\\\#\{/, output_haml, "Backslashes should be escaped in HAML")
  end
end
