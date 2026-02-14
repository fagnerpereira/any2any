# frozen_string_literal: true

module Haml2Slim
  VERSION = "0.1.0"
end

# Backwards-compatible alias for gem naming
module Haml2Slim
  VERSION = Haml2Slim::VERSION unless const_defined?(:VERSION)
end
