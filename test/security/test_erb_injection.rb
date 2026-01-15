# frozen_string_literal: true

require "test_helper"

class TestErbInjection < Minitest::Test
  def test_static_content_with_erb_tag_is_escaped
    # Simulating static content containing ERB tags
    # This could happen if converting from another format where this text is just a string
    # For example, in HAML: %p <% puts 'pwned' %>

    # We construct the IR manually to ensure we are testing the Generator,
    # independent of the Parser's behavior (though parser should also handle this correctly).

    static_content = Any2Any::IR::StaticContent.new(text: "<% puts 'pwned' %>")
    p_element = Any2Any::IR::Element.new(tag_name: "p", children: [static_content])

    template = Any2Any::IR::Template.new(children: [p_element])

    generator = Any2Any::Generators::ErbGenerator.new
    output = generator.generate(template)

    # We expect the opening tag to be escaped as <%%
    assert_includes output, "<%% puts 'pwned' %>"
    refute_includes output, "<% puts 'pwned' %>"
  end
end
