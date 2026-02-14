# frozen_string_literal: true

require "phlex2slim/version"
require "phlex2slim/errors"
require "phlex2slim/ir/node"
require "phlex2slim/ir/template"
require "phlex2slim/ir/element"
require "phlex2slim/ir/expression"
require "phlex2slim/ir/block"
require "phlex2slim/ir/conditional"
require "phlex2slim/ir/loop"
require "phlex2slim/ir/static_content"
require "phlex2slim/ir/comment"
require "phlex2slim/ir/visitor"
require "phlex2slim/parsers/base_parser"
require "phlex2slim/parsers/phlex_parser"
require "phlex2slim/generators/base_generator"
require "phlex2slim/generators/slim_generator"
require "phlex2slim/transformers/normalizer"
require "phlex2slim/transformers/optimizer"
require "phlex2slim/transformers/validator"
require "phlex2slim/converter"
require "phlex2slim/cli"

module Phlex2Slim
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
