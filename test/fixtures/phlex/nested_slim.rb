# frozen_string_literal: true

# Phlex version of nested.slim: div > p "Hello World"
class NestedSlimComponent < Phlex::HTML
  def view_template
    div do
      p { "Hello World" }
    end
  end
end
