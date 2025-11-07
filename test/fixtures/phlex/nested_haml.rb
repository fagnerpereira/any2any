# frozen_string_literal: true

# Phlex version of nested.haml: %div > %p "Hello World"
class NestedHamlComponent < Phlex::HTML
  def view_template
    div do
      p { "Hello World" }
    end
  end
end
