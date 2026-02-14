# frozen_string_literal: true

module Haml2Phlex
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Haml2Phlex
  VERSION = Haml2Phlex::VERSION unless const_defined?(:VERSION)
end
