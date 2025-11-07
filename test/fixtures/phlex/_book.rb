# frozen_string_literal: true

# Phlex version of _book.html.erb
class BookPartial < Phlex::HTML
  def initialize(book:)
    @book = book
  end

  def view_template
    div(id: dom_id(@book), class: "w-full sm:w-auto my-5 space-y-5") do
      div do
        strong(class: "block font-medium mb-1") { "Name:" }
        plain @book.name
      end
      div do
        strong(class: "block font-medium mb-1") { "Author:" }
        plain @book.author
      end
    end
  end

  private

  def dom_id(record)
    "#{record.class.name.downcase}_#{record.id}"
  end
end
