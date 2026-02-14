# frozen_string_literal: true

module Slim2Erb
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Slim2Erb
  VERSION = Slim2Erb::VERSION unless const_defined?(:VERSION)
end
