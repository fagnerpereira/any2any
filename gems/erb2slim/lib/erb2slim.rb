# frozen_string_literal: true

require "erb2slim/version"
require "erb2slim/errors"
require "erb2slim/ir/node"
require "erb2slim/ir/template"
require "erb2slim/ir/element"
require "erb2slim/ir/expression"
require "erb2slim/ir/block"
require "erb2slim/ir/conditional"
require "erb2slim/ir/loop"
require "erb2slim/ir/static_content"
require "erb2slim/ir/comment"
require "erb2slim/ir/visitor"
require "erb2slim/parsers/base_parser"
require "erb2slim/parsers/erb_parser"
require "erb2slim/generators/base_generator"
require "erb2slim/generators/slim_generator"
require "erb2slim/transformers/normalizer"
require "erb2slim/transformers/optimizer"
require "erb2slim/transformers/validator"
require "erb2slim/converter"
require "erb2slim/cli"

module Erb2Slim
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
