# frozen_string_literal: true

require "erb2phlex/version"
require "erb2phlex/errors"
require "erb2phlex/ir/node"
require "erb2phlex/ir/template"
require "erb2phlex/ir/element"
require "erb2phlex/ir/expression"
require "erb2phlex/ir/block"
require "erb2phlex/ir/conditional"
require "erb2phlex/ir/loop"
require "erb2phlex/ir/static_content"
require "erb2phlex/ir/comment"
require "erb2phlex/ir/visitor"
require "erb2phlex/parsers/base_parser"
require "erb2phlex/parsers/erb_parser"
require "erb2phlex/generators/base_generator"
require "erb2phlex/generators/phlex_generator"
require "erb2phlex/transformers/normalizer"
require "erb2phlex/transformers/optimizer"
require "erb2phlex/transformers/validator"
require "erb2phlex/converter"
require "erb2phlex/cli"

module Erb2Phlex
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
