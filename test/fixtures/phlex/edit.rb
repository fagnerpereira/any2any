# frozen_string_literal: true

# Phlex version of edit.html.erb
class Edit < Phlex::HTML
  def initialize(book:)
    @book = book
  end

  def view_template
    div(class: "md:w-2/3 w-full") do
      h1(class: "font-bold text-4xl") { "Editing book" }

      # Note: form rendering would require Rails form helpers
      comment "Form would go here - requires Rails form helpers"

      a(
        href: book_path(@book),
        class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      ) { "Show this book" }

      a(
        href: books_path,
        class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      ) { "Back to books" }
    end
  end

  private

  def book_path(book)
    "/books/#{book.id}"
  end

  def books_path
    "/books"
  end
end
