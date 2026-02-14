# frozen_string_literal: true

module Erb2Slim
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Erb2Slim
  VERSION = Erb2Slim::VERSION unless const_defined?(:VERSION)
end
