# frozen_string_literal: true

require "slim2haml/version"
require "slim2haml/errors"
require "slim2haml/ir/node"
require "slim2haml/ir/template"
require "slim2haml/ir/element"
require "slim2haml/ir/expression"
require "slim2haml/ir/block"
require "slim2haml/ir/conditional"
require "slim2haml/ir/loop"
require "slim2haml/ir/static_content"
require "slim2haml/ir/comment"
require "slim2haml/ir/visitor"
require "slim2haml/parsers/base_parser"
require "slim2haml/parsers/slim_parser"
require "slim2haml/generators/base_generator"
require "slim2haml/generators/haml_generator"
require "slim2haml/transformers/normalizer"
require "slim2haml/transformers/optimizer"
require "slim2haml/transformers/validator"
require "slim2haml/converter"
require "slim2haml/cli"

module Slim2Haml
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
