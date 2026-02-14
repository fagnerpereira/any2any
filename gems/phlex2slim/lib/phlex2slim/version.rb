# frozen_string_literal: true

module Phlex2Slim
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Phlex2Slim
  VERSION = Phlex2Slim::VERSION unless const_defined?(:VERSION)
end
