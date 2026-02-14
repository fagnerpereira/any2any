# frozen_string_literal: true

require "phlex2haml/version"
require "phlex2haml/errors"
require "phlex2haml/ir/node"
require "phlex2haml/ir/template"
require "phlex2haml/ir/element"
require "phlex2haml/ir/expression"
require "phlex2haml/ir/block"
require "phlex2haml/ir/conditional"
require "phlex2haml/ir/loop"
require "phlex2haml/ir/static_content"
require "phlex2haml/ir/comment"
require "phlex2haml/ir/visitor"
require "phlex2haml/parsers/base_parser"
require "phlex2haml/parsers/phlex_parser"
require "phlex2haml/generators/base_generator"
require "phlex2haml/generators/haml_generator"
require "phlex2haml/transformers/normalizer"
require "phlex2haml/transformers/optimizer"
require "phlex2haml/transformers/validator"
require "phlex2haml/converter"
require "phlex2haml/cli"

module Phlex2Haml
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
