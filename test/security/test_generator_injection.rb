require_relative "../test_helper"

class TestGeneratorInjection < Minitest::Test
  def test_erb_static_content_injection
    # Payload that would execute system command if not escaped
    payload = "<% system('echo ERB_INJECTION') %>"
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::StaticContent.new(text: "Hello #{payload} World")
    ])

    generator = Any2Any::Generators::ErbGenerator.new
    output = generator.generate(ir)

    # Should escape <% to <%%
    assert_includes output, "<%% system('echo ERB_INJECTION') %>"
    refute_includes output, "<% system"
  end

  def test_haml_static_content_injection
    # Payload that would execute system command if not escaped
    # Use single quotes to avoid interpolation in test file itself
    payload = '#{system(\'echo HAML_INJECTION\')}'
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::StaticContent.new(text: "Hello #{payload} World")
    ])

    generator = Any2Any::Generators::HamlGenerator.new
    output = generator.generate(ir)

    # Should escape #{ to \#{
    expected_fragment = '\\#{system(\'echo HAML_INJECTION\')}'
    assert_includes output, expected_fragment
  end

  def test_haml_attribute_injection
    # Payload in attribute
    payload = '#{system(\'echo HAML_ATTR_INJECTION\')}'
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::Element.new(
        tag_name: "div",
        attributes: { "data-val" => payload }
      )
    ])

    generator = Any2Any::Generators::HamlGenerator.new
    output = generator.generate(ir)

    # HAML attributes: data-val: "..."
    # Should escape #{ to \#{ inside the string
    expected_fragment = '\\#{system(\'echo HAML_ATTR_INJECTION\')}'
    assert_includes output, expected_fragment
  end

  def test_slim_static_content_injection
    # Payload that would execute system command if not escaped
    payload = '#{system(\'echo SLIM_INJECTION\')}'
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::StaticContent.new(text: "Hello #{payload} World")
    ])

    generator = Any2Any::Generators::SlimGenerator.new
    output = generator.generate(ir)

    # Should escape #{ to \#{
    expected_fragment = '\\#{system(\'echo SLIM_INJECTION\')}'
    assert_includes output, expected_fragment
  end

  def test_slim_attribute_injection
    # Payload in attribute
    payload = '#{system(\'echo SLIM_ATTR_INJECTION\')}'
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::Element.new(
        tag_name: "div",
        attributes: { "data-val" => payload }
      )
    ])

    generator = Any2Any::Generators::SlimGenerator.new
    output = generator.generate(ir)

    # Slim attributes: data-val="..."
    # Should escape #{ to \#{
    expected_fragment = '\\#{system(\'echo SLIM_ATTR_INJECTION\')}'
    assert_includes output, expected_fragment
  end

  def test_haml_attribute_correctness
    # Regression test: quotes and backslashes should be handled correctly for Ruby strings
    # Input value: Quote " and Backslash \
    payload = 'Quote " and Backslash \\'
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::Element.new(
        tag_name: "div",
        attributes: { "data-val" => payload }
      )
    ])

    generator = Any2Any::Generators::HamlGenerator.new
    output = generator.generate(ir)

    # Expected output: data-val: "Quote \" and Backslash \\"
    # We should NOT see &quot;
    assert_includes output, 'Quote \"'
    refute_includes output, '&quot;'
    assert_includes output, 'Backslash \\\\'
  end

  def test_slim_attribute_correctness
    # Regression test: quotes and backslashes
    payload = 'Quote " and Backslash \\'
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::Element.new(
        tag_name: "div",
        attributes: { "data-val" => payload }
      )
    ])

    generator = Any2Any::Generators::SlimGenerator.new
    output = generator.generate(ir)

    # Expected output: data-val="Quote \" and Backslash \\"
    assert_includes output, 'Quote \"'
    refute_includes output, '&quot;'
    assert_includes output, 'Backslash \\\\'
  end

  def test_backslash_escaping_haml
    # Input: \ (literal backslash)
    payload = "\\"
    ir = Any2Any::IR::Template.new(children: [
      Any2Any::IR::StaticContent.new(text: payload)
    ])

    generator = Any2Any::Generators::HamlGenerator.new
    output = generator.generate(ir)

    # Output should contain \\
    assert_match /\\/, output.strip
  end
end
