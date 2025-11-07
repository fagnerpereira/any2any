# frozen_string_literal: true

# Example Phlex component fixture
class SimpleComponent < Phlex::HTML
  def template
    div do
      p { plain "Hello" }
    end
  end
end
