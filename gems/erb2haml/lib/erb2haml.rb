# frozen_string_literal: true

require "erb2haml/version"
require "erb2haml/errors"
require "erb2haml/ir/node"
require "erb2haml/ir/template"
require "erb2haml/ir/element"
require "erb2haml/ir/expression"
require "erb2haml/ir/block"
require "erb2haml/ir/conditional"
require "erb2haml/ir/loop"
require "erb2haml/ir/static_content"
require "erb2haml/ir/comment"
require "erb2haml/ir/visitor"
require "erb2haml/parsers/base_parser"
require "erb2haml/parsers/erb_parser"
require "erb2haml/generators/base_generator"
require "erb2haml/generators/haml_generator"
require "erb2haml/transformers/normalizer"
require "erb2haml/transformers/optimizer"
require "erb2haml/transformers/validator"
require "erb2haml/converter"
require "erb2haml/cli"

module Erb2Haml
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
