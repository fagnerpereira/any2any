# frozen_string_literal: true

module Any2Any
  VERSION = '0.1.0'
end

# Backwards-compatible alias for gem naming
module Any2Any
  VERSION = Any2Any::VERSION unless const_defined?(:VERSION)
end
