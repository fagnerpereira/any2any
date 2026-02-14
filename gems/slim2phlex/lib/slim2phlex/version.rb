# frozen_string_literal: true

module Slim2Phlex
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Slim2Phlex
  VERSION = Slim2Phlex::VERSION unless const_defined?(:VERSION)
end
