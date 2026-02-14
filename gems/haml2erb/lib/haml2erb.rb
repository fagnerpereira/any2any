# frozen_string_literal: true

require "haml2erb/version"
require "haml2erb/errors"
require "haml2erb/ir/node"
require "haml2erb/ir/template"
require "haml2erb/ir/element"
require "haml2erb/ir/expression"
require "haml2erb/ir/block"
require "haml2erb/ir/conditional"
require "haml2erb/ir/loop"
require "haml2erb/ir/static_content"
require "haml2erb/ir/comment"
require "haml2erb/ir/visitor"
require "haml2erb/parsers/base_parser"
require "haml2erb/parsers/haml_parser"
require "haml2erb/generators/base_generator"
require "haml2erb/generators/erb_generator"
require "haml2erb/transformers/normalizer"
require "haml2erb/transformers/optimizer"
require "haml2erb/transformers/validator"
require "haml2erb/converter"
require "haml2erb/cli"

module Haml2Erb
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
