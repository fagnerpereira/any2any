require "test_helper"

class TestSlimInjection < Minitest::Test
  include Any2Any::IR

  def setup
    @generator = Any2Any::Generators::SlimGenerator.new
  end

  def test_prevents_interpolation_injection_in_static_content
    # Input: #{system('echo pwned')}
    # Expected Slim: | \#{system('echo pwned')}
    content = StaticContent.new(text: "\#{system('echo pwned')}")
    template = Template.new(children: [content])

    output = @generator.generate(template)

    # Verify the output escapes #{
    # We expect the output to contain \#{ which in ruby string is "\\\#{"
    assert_includes output, "\\\#{"

    # Verify full output structure
    assert_match(/\|\s+\\\#\{system/, output)
  end

  def test_prevents_multiline_tag_injection
    # Input: line1\nscript alert(1)
    # Expected Slim:
    # | line1
    # | script alert(1)
    content = StaticContent.new(text: "line1\nscript alert(1)")
    template = Template.new(children: [content])

    output = @generator.generate(template)

    lines = output.split("\n")
    assert_operator lines.size, :>=, 2

    # Verify strict prefixing
    # Check that the second line is prefixed with |
    # This ensures it's treated as text, not a tag
    assert_match(/\|\s+line1/, lines[0])
    assert_match(/\|\s+script alert\(1\)/, lines[1])
  end

  def test_handles_backslashes_correctly
    # Input: \
    # Expected output: | \
    # Rendered result: \
    content = StaticContent.new(text: "\\")
    template = Template.new(children: [content])
    output = @generator.generate(template)

    assert_match(/\|\s+\\$/, output)
  end

  def test_handles_double_backslashes_correctly
    # Input: \\
    # Expected output: | \\
    # Rendered result: \\
    content = StaticContent.new(text: "\\\\")
    template = Template.new(children: [content])
    output = @generator.generate(template)

    assert_match(/\|\s+\\\\/, output)
  end

  def test_handles_mixed_escaped_interpolation
    # Input: \#{foo}
    # Expected output: | \\#{foo}
    # Rendered result: \#{foo}
    content = StaticContent.new(text: "\\\#{foo}")
    template = Template.new(children: [content])
    output = @generator.generate(template)

    # We expect output to contain \\#{
    assert_includes output, "\\\\\#{"
  end

  def test_prevents_interpolation_in_attributes
    # Input: class="#{bad}"
    # Expected Slim: div class="\#{bad}"
    # Rendered HTML: <div class="#{bad}"></div>
    element = Element.new(tag_name: "div", attributes: { class: "\#{bad}" })
    template = Template.new(children: [element])
    output = @generator.generate(template)

    assert_includes output, 'class="\#{bad}"'
  end

  def test_prevents_multiline_in_inline_element
    # Input: div text\nmore
    # Expected:
    # div
    #   | text
    #   | more
    # NOT: div text\nmore

    text = "text\nmore"
    content = StaticContent.new(text: text)
    element = Element.new(tag_name: "div", children: [content])
    template = Template.new(children: [element])
    output = @generator.generate(template)

    lines = output.split("\n")
    # First line should be just div (maybe with attributes)
    assert_match(/^\s*div$/, lines[0])

    # Should NOT have text on the first line
    refute_match(/^\s*div\s+text/, lines[0])

    # Subsequent lines should be text
    assert_match(/^\s*\|\s+text$/, lines[1])
    assert_match(/^\s*\|\s+more$/, lines[2])
  end
end
