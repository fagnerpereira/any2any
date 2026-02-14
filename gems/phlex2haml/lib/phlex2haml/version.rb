# frozen_string_literal: true

module Phlex2Haml
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Phlex2Haml
  VERSION = Phlex2Haml::VERSION unless const_defined?(:VERSION)
end
