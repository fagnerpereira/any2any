# frozen_string_literal: true

module Slim2Haml
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Slim2Haml
  VERSION = Slim2Haml::VERSION unless const_defined?(:VERSION)
end
