# frozen_string_literal: true

require "slim2erb/version"
require "slim2erb/errors"
require "slim2erb/ir/node"
require "slim2erb/ir/template"
require "slim2erb/ir/element"
require "slim2erb/ir/expression"
require "slim2erb/ir/block"
require "slim2erb/ir/conditional"
require "slim2erb/ir/loop"
require "slim2erb/ir/static_content"
require "slim2erb/ir/comment"
require "slim2erb/ir/visitor"
require "slim2erb/parsers/base_parser"
require "slim2erb/parsers/slim_parser"
require "slim2erb/generators/base_generator"
require "slim2erb/generators/erb_generator"
require "slim2erb/transformers/normalizer"
require "slim2erb/transformers/optimizer"
require "slim2erb/transformers/validator"
require "slim2erb/converter"
require "slim2erb/cli"

module Slim2Erb
  class << self
    def convert(source, options: {})
      Converter.new(options).convert(source)
    end
  end
end
