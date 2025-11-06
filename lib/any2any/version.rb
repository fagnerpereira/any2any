# frozen_string_literal: true

module TemplateConverter
  VERSION = '0.1.0'
end

# Backwards-compatible alias for gem naming
module Any2Any
  VERSION = TemplateConverter::VERSION unless const_defined?(:VERSION)
end
