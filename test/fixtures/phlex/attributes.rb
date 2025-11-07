# frozen_string_literal: true

# Phlex version of attributes.slim: div.container > p#intro.text "Hello"
class AttributesComponent < Phlex::HTML
  def view_template
    div(class: "container") do
      p(id: "intro", class: "text") { "Hello" }
    end
  end
end
