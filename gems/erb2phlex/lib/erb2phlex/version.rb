# frozen_string_literal: true

module Erb2Phlex
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Erb2Phlex
  VERSION = Erb2Phlex::VERSION unless const_defined?(:VERSION)
end
