# frozen_string_literal: true

require "phlex2erb/version"
require "phlex2erb/errors"
require "phlex2erb/ir/node"
require "phlex2erb/ir/template"
require "phlex2erb/ir/element"
require "phlex2erb/ir/expression"
require "phlex2erb/ir/block"
require "phlex2erb/ir/conditional"
require "phlex2erb/ir/loop"
require "phlex2erb/ir/static_content"
require "phlex2erb/ir/comment"
require "phlex2erb/ir/visitor"
require "phlex2erb/parsers/base_parser"
require "phlex2erb/parsers/phlex_parser"
require "phlex2erb/generators/base_generator"
require "phlex2erb/generators/erb_generator"
require "phlex2erb/transformers/normalizer"
require "phlex2erb/transformers/optimizer"
require "phlex2erb/transformers/validator"
require "phlex2erb/converter"
require "phlex2erb/cli"

module Phlex2Erb
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
