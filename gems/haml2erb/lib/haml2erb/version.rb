# frozen_string_literal: true

module Haml2Erb
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Haml2Erb
  VERSION = Haml2Erb::VERSION unless const_defined?(:VERSION)
end
