# frozen_string_literal: true

# Phlex version of with_expression.slim: div > p= @name
class WithExpressionSlimComponent < Phlex::HTML
  def initialize(name:)
    @name = name
  end

  def view_template
    div do
      p { @name }
    end
  end
end
