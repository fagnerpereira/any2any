require "test_helper"

class TestErbGeneratorSecurity < Minitest::Test
  def setup
    @generator = Any2Any::Generators::ErbGenerator.new
  end

  def test_escapes_erb_tags_in_static_content
    # Vulnerability: <% system(...) %> in static content should be escaped
    # so it is rendered as text, not executed as code.

    malicious_content = "<% system('echo hacked') %>"
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: malicious_content)
      ]
    )

    output = @generator.generate(ir)

    # We expect <%% which escapes the tag in ERB
    assert_includes output, "<%% system('echo hacked') %>"
    refute_includes output, "<% system"
  end

  def test_escapes_erb_interpolation_in_static_content
    # Vulnerability: <%= ... %>
    content = "<%= 1 + 1 %>"
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: content)
      ]
    )

    output = @generator.generate(ir)
    assert_includes output, "<%%= 1 + 1 %>"
  end

  def test_escapes_erb_comment_in_static_content
    # Vulnerability: <%# ... %>
    content = "<%# comment %>"
    ir = Any2Any::IR::Template.new(
      children: [
        Any2Any::IR::StaticContent.new(text: content)
      ]
    )

    output = @generator.generate(ir)
    assert_includes output, "<%%# comment %>"
  end
end
