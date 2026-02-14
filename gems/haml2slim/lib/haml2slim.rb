# frozen_string_literal: true

require "haml2slim/version"
require "haml2slim/errors"
require "haml2slim/ir/node"
require "haml2slim/ir/template"
require "haml2slim/ir/element"
require "haml2slim/ir/expression"
require "haml2slim/ir/block"
require "haml2slim/ir/conditional"
require "haml2slim/ir/loop"
require "haml2slim/ir/static_content"
require "haml2slim/ir/comment"
require "haml2slim/ir/visitor"
require "haml2slim/parsers/base_parser"
require "haml2slim/parsers/haml_parser"
require "haml2slim/generators/base_generator"
require "haml2slim/generators/slim_generator"
require "haml2slim/transformers/normalizer"
require "haml2slim/transformers/optimizer"
require "haml2slim/transformers/validator"
require "haml2slim/converter"
require "haml2slim/cli"

module Haml2Slim
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
