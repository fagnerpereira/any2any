# frozen_string_literal: true

# Phlex version of index.html.erb
class Index < Phlex::HTML
  def initialize(books:, notice: nil)
    @books = books
    @notice = notice
  end

  def view_template
    # Note: content_for is a Rails-specific helper, skipped in pure Phlex
    div(class: "w-full") do
      if @notice.present?
        p(
          class: "py-2 px-3 bg-green-50 mb-5 text-green-500 font-medium rounded-md inline-block",
          id: "notice"
        ) { @notice }
      end

      div(class: "flex justify-between items-center") do
        h1(class: "font-bold text-4xl") { "Books" }
        a(
          href: new_book_path,
          class: "rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white block font-medium"
        ) { "New book" }
      end

      div(id: "books", class: "min-w-full divide-y divide-gray-200 space-y-5") do
        if @books.any?
          @books.each do |book|
            div(class: "flex flex-col sm:flex-row justify-between items-center pb-5 sm:pb-0") do
              render BookPartial.new(book: book)
              div(class: "w-full sm:w-auto flex flex-col sm:flex-row space-x-2 space-y-2") do
                a(
                  href: book_path(book),
                  class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
                ) { "Show" }
                a(
                  href: edit_book_path(book),
                  class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium"
                ) { "Edit" }
                # Note: button_to is Rails-specific, would need custom implementation
                comment "Destroy button would go here - requires Rails helpers"
              end
            end
          end
        else
          p(class: "text-center my-10") { "No books found." }
        end
      end
    end
  end

  private

  def new_book_path
    "/books/new"
  end

  def book_path(book)
    "/books/#{book.id}"
  end

  def edit_book_path(book)
    "/books/#{book.id}/edit"
  end
end
