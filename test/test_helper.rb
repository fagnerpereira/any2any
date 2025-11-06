# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/reporters'
require 'simplecov'

# Setup coverage
SimpleCov.start do
  add_filter '/test/'
end

# Setup test reporters
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Load the gem
require 'any2any'

class Minitest::Test
  def fixtures_dir
    File.expand_path('../fixtures', __dir__)
  end

  def fixture_path(format, name)
    File.join(fixtures_dir, format.to_s, "#{name}.#{format}")
  end

  def read_fixture(format, name)
    File.read(fixture_path(format, name))
  end
end
