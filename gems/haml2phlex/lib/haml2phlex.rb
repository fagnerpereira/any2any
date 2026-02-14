# frozen_string_literal: true

require "haml2phlex/version"
require "haml2phlex/errors"
require "haml2phlex/ir/node"
require "haml2phlex/ir/template"
require "haml2phlex/ir/element"
require "haml2phlex/ir/expression"
require "haml2phlex/ir/block"
require "haml2phlex/ir/conditional"
require "haml2phlex/ir/loop"
require "haml2phlex/ir/static_content"
require "haml2phlex/ir/comment"
require "haml2phlex/ir/visitor"
require "haml2phlex/parsers/base_parser"
require "haml2phlex/parsers/haml_parser"
require "haml2phlex/generators/base_generator"
require "haml2phlex/generators/phlex_generator"
require "haml2phlex/transformers/normalizer"
require "haml2phlex/transformers/optimizer"
require "haml2phlex/transformers/validator"
require "haml2phlex/converter"
require "haml2phlex/cli"

module Haml2Phlex
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
