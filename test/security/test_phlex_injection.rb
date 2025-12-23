require 'test_helper'

class TestPhlexInjection < Minitest::Test
  def setup
    @converter = Any2Any::Converter.new
  end

  def test_prevents_code_injection_in_phlex_static_content
    # This ERB content is just text "Hello #{system('echo injected')}"
    # In ERB, this is static text because it's not inside <% %>.
    erb_source = "Hello \#{system('echo injected')}"

    result = @converter.convert(erb_source, from: :erb, to: :phlex)
    output = result[:output]

    # Generated code should be: plain "Hello \#{system...}"
    # This prevents interpolation because \# in double quotes is just #.
    # Assertion string: plain "Hello \\#{system...}"

    assert_includes output, 'plain "Hello \\#{system(\'echo injected\')}"'
  end

  def test_prevents_code_injection_in_phlex_attributes
    # ERB input with attribute containing interpolation syntax
    # Use 'class' to avoid Ruby syntax errors with dashed keys
    erb_source = '<div class="\#{system(\'echo injected\')}"></div>'

    result = @converter.convert(erb_source, from: :erb, to: :phlex)
    output = result[:output]

    # Input has \#{
    # Generated code should have \\\#{ (3 backslashes).
    # Assertion string needs 6 backslashes to match 3 backslashes.

    assert_includes output, 'class: "\\\\\\#{system(\'echo injected\')}"'
  end
end
