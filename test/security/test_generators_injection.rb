require_relative '../test_helper'

class TestGeneratorsInjection < Minitest::Test
  def setup
    @erb_generator = Any2Any::Generators::ErbGenerator.new
    @haml_generator = Any2Any::Generators::HamlGenerator.new
    @slim_generator = Any2Any::Generators::SlimGenerator.new
  end

  def create_template(text)
    Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: text)
      ]
    )
  end

  def create_element_with_attribute(attr_value)
    Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(
          tag_name: 'div',
          attributes: { 'data-val' => attr_value }
        )
      ]
    )
  end

  # ERB Injection Tests
  def test_erb_escapes_tags_in_static_content
    template = create_template('<% system("rm -rf /") %>')
    output = @erb_generator.generate(template)
    # ERB uses <%% to escape <%
    assert_includes output, '<%%'
    refute_includes output, '<% system'
  end

  # HAML Injection Tests
  def test_haml_escapes_interpolation_in_static_content
    template = create_template('#{system("rm -rf /")}')
    output = @haml_generator.generate(template)
    # Should be \#{...}
    assert_includes output, '\#{system'
    # Ensure it's not double escaped or unescaped
    # We want exactly \#{system... (ignoring indentation)
    assert_match(/^\s*\\#\{system/, output)
  end

  def test_haml_escapes_interpolation_in_attributes
    template = create_element_with_attribute('#{system("rm -rf /")}')
    output = @haml_generator.generate(template)
    # Attributes in HAML can use Ruby hash syntax or HTML style
    # We expect escaped interpolation
    assert_includes output, '\#{'
    # Check that we don't have unescaped #{.
    # Since we can't easily rely on string includes, we use regex to ensure backslash precedes #{
    # But backslash itself needs to be single.
    # We expect ...: "\#{system...}"
    assert_match(/: "\\#\{system/, output)
  end

  def test_haml_handles_start_of_line_chars
    chars = %w[% . # = - ~ / !]
    chars.each do |char|
      template = create_template("#{char}danger")
      output = @haml_generator.generate(template)
      # HAML escapes start of line with \ if it's special
      # output should be \char...
      assert_match(/^\s*\\#{Regexp.escape(char)}/, output)
    end
  end

  def test_haml_handles_multiline_content
    template = create_template("line1\nline2")
    output = @haml_generator.generate(template)
    lines = output.split("\n")
    # Both lines should be indented if they are inside something, but here they are at root.
    # But if we put them inside a div:

    div_template = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::Element.new(
          tag_name: 'div',
          children: [
            Any2Any::IR::StaticContent.new(text: "line1\nline2")
          ]
        )
      ]
    )
    output = @haml_generator.generate(div_template)
    # Output should be:
    # %div
    #   line1
    #   line2

    lines = output.split("\n")
    assert_equal 3, lines.length
    assert_equal "  line1", lines[1]
    assert_equal "  line2", lines[2]
  end

  # Slim Injection Tests
  def test_slim_escapes_interpolation_in_static_content
    template = create_template('#{system("rm -rf /")}')
    output = @slim_generator.generate(template)
    assert_includes output, '\#{'
    # Expected: | \#{system...}
    assert_match(/\|\s*\\#\{system/, output)
  end

  def test_slim_escapes_interpolation_in_attributes
    template = create_element_with_attribute('#{system("rm -rf /")}')
    output = @slim_generator.generate(template)
    assert_includes output, '\#{'
    # Expected: ... data-val="\#{system..."
    assert_match(/data-val="\\#\{system/, output)
  end

  def test_slim_handles_multiline_content_safely
    # Check for tag injection via newline
    template = create_template("line1\nscript alert(1)")
    output = @slim_generator.generate(template)
    # Should use | for each line
    lines = output.split("\n")
    assert lines.all? { |l| l.strip.start_with?('|') }
    assert_includes output, '| script alert(1)'
  end
end
