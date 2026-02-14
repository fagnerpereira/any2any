# frozen_string_literal: true

require "slim2phlex/version"
require "slim2phlex/errors"
require "slim2phlex/ir/node"
require "slim2phlex/ir/template"
require "slim2phlex/ir/element"
require "slim2phlex/ir/expression"
require "slim2phlex/ir/block"
require "slim2phlex/ir/conditional"
require "slim2phlex/ir/loop"
require "slim2phlex/ir/static_content"
require "slim2phlex/ir/comment"
require "slim2phlex/ir/visitor"
require "slim2phlex/parsers/base_parser"
require "slim2phlex/parsers/slim_parser"
require "slim2phlex/generators/base_generator"
require "slim2phlex/generators/phlex_generator"
require "slim2phlex/transformers/normalizer"
require "slim2phlex/transformers/optimizer"
require "slim2phlex/transformers/validator"
require "slim2phlex/converter"
require "slim2phlex/cli"

module Slim2Phlex
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
