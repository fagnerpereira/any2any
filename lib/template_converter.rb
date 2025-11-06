# frozen_string_literal: true

require 'template_converter/version'
require 'template_converter/errors'
require 'template_converter/ir/node'
require 'template_converter/ir/template'
require 'template_converter/ir/element'
require 'template_converter/ir/expression'
require 'template_converter/ir/block'
require 'template_converter/ir/conditional'
require 'template_converter/ir/loop'
require 'template_converter/ir/static_content'
require 'template_converter/ir/comment'
require 'template_converter/ir/visitor'
require 'template_converter/parsers/base_parser'
require 'template_converter/parsers/slim_parser'
require 'template_converter/parsers/haml_parser'
require 'template_converter/parsers/erb_parser'
require 'template_converter/generators/base_generator'
require 'template_converter/generators/slim_generator'
require 'template_converter/generators/haml_generator'
require 'template_converter/generators/erb_generator'
require 'template_converter/transformers/normalizer'
require 'template_converter/transformers/optimizer'
require 'template_converter/transformers/validator'
require 'template_converter/converter'
require 'template_converter/cli'

module TemplateConverter
  class << self
    # Simple conversion API
    def convert(source, from:, to:, options: {})
      Converter.new(options).convert(source, from: from, to: to)
    end
  end
end
