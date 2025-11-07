# frozen_string_literal: true

# Phlex version of show.html.erb
class Show < Phlex::HTML
  def initialize(book:, notice: nil)
    @book = book
    @notice = notice
  end

  def view_template
    div(class: "md:w-2/3 w-full") do
      if @notice.present?
        p(
          class: "py-2 px-3 bg-green-50 mb-5 text-green-500 font-medium rounded-md inline-block",
          id: "notice"
        ) { @notice }
      end

      h1(class: "font-bold text-4xl") { "Showing book" }

      render BookPartial.new(book: @book)

      a(
        href: edit_book_path(@book),
        class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      ) { "Edit this book" }

      a(
        href: books_path,
        class: "w-full sm:w-auto text-center mt-2 sm:mt-0 sm:ml-2 rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
      ) { "Back to books" }

      # Note: button_to is Rails-specific
      comment "Destroy button would go here - requires Rails helpers"
    end
  end

  private

  def edit_book_path(book)
    "/books/#{book.id}/edit"
  end

  def books_path
    "/books"
  end
end
