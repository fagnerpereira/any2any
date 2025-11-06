# frozen_string_literal: true

module TemplateConverter
  module IR
    # Base class for all IR nodes
    class Node
      attr_reader :source_location

      def initialize(source_location: nil)
        @source_location = source_location
      end

      def accept(visitor)
        visitor.visit(self)
      end

      def ==(other)
        other.is_a?(self.class) &&
          instance_variables.all? { |var| instance_variable_get(var) == other.instance_variable_get(var) }
      end

      def inspect
        attrs = instance_variables.map { |var| "#{var}=#{instance_variable_get(var).inspect}" }.join(', ')
        "#<#{self.class.name}:#{object_id} #{attrs}>"
      end
    end
  end
end
