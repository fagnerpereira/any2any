# frozen_string_literal: true

module Phlex2Erb
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Phlex2Erb
  VERSION = Phlex2Erb::VERSION unless const_defined?(:VERSION)
end
