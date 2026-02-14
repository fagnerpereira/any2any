# frozen_string_literal: true

module Erb2Haml
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Erb2Haml
  VERSION = Erb2Haml::VERSION unless const_defined?(:VERSION)
end
