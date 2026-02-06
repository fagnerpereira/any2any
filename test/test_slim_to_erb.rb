# frozen_string_literal: true

require "test_helper"

class TestSlimToErb < Minitest::Test
  def test_application_layout_conversion
    slim_content = read_fixture(:slim, "application.html")
    converter = Any2Any::Converter.new

    result = converter.convert(slim_content, from: :slim, to: :erb)
    # binding.break
    assert result[:output].include?("<div>")
  end
end
