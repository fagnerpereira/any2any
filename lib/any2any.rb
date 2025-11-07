# frozen_string_literal: true

require 'any2any/version'
require 'any2any/errors'
require 'any2any/ir/node'
require 'any2any/ir/template'
require 'any2any/ir/element'
require 'any2any/ir/expression'
require 'any2any/ir/block'
require 'any2any/ir/conditional'
require 'any2any/ir/loop'
require 'any2any/ir/static_content'
require 'any2any/ir/comment'
require 'any2any/ir/visitor'
require 'any2any/parsers/base_parser'
require 'any2any/parsers/slim_parser'
require 'any2any/parsers/haml_parser'
require 'any2any/parsers/erb_parser'
require 'any2any/parsers/phlex_parser'
require 'any2any/generators/base_generator'
require 'any2any/generators/slim_generator'
require 'any2any/generators/haml_generator'
require 'any2any/generators/erb_generator'
require 'any2any/generators/phlex_generator'
require 'any2any/transformers/normalizer'
require 'any2any/transformers/optimizer'
require 'any2any/transformers/validator'
require 'any2any/converter'
require 'any2any/cli'

module Any2Any
  class << self
    # Simple conversion API
    def convert(source, from:, to:, options: {})
      Converter.new(options).convert(source, from: from, to: to)
    end
  end
end

# Public API under the gem name
# Backwards-compatible alias so both Any2Any and Any2Any work
Any2Any = Any2Any unless defined?(Any2Any)
