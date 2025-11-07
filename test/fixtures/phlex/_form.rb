# frozen_string_literal: true

# Phlex version of _form.html.erb
class FormPartial < Phlex::HTML
  def initialize(book:)
    @book = book
  end

  def view_template
    # Note: form_with is a Rails helper - in pure Phlex this would be custom
    # This is a conceptual translation showing the structure
    comment "Form would use form_with helper in Rails"

    # Error messages section
    if @book.errors.any?
      div(
        id: "error_explanation",
        class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3"
      ) do
        h2 { "#{pluralize(@book.errors.count, 'error')} prohibited this book from being saved:" }

        ul(class: "list-disc ml-6") do
          @book.errors.each do |error|
            li { error.full_message }
          end
        end
      end
    end

    # Name field
    div(class: "my-5") do
      label(for: "book_name") { "Name" }
      input(
        type: "text",
        name: "book[name]",
        id: "book_name",
        class: name_field_classes,
        value: @book.name
      )
    end

    # Author field
    div(class: "my-5") do
      label(for: "book_author") { "Author" }
      input(
        type: "text",
        name: "book[author]",
        id: "book_author",
        class: author_field_classes,
        value: @book.author
      )
    end

    # Submit button
    div(class: "inline") do
      input(
        type: "submit",
        value: "Save Book",
        class: "w-full sm:w-auto rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white inline-block font-medium cursor-pointer"
      )
    end
  end

  private

  def name_field_classes
    base = "block shadow-sm rounded-md border px-3 py-2 mt-2 w-full"
    if @book.errors[:name].none?
      "#{base} border-gray-400 focus:outline-blue-600"
    else
      "#{base} border-red-400 focus:outline-red-600"
    end
  end

  def author_field_classes
    base = "block shadow-sm rounded-md border px-3 py-2 mt-2 w-full"
    if @book.errors[:author].none?
      "#{base} border-gray-400 focus:outline-blue-600"
    else
      "#{base} border-red-400 focus:outline-red-600"
    end
  end

  def pluralize(count, singular)
    count == 1 ? "#{count} #{singular}" : "#{count} #{singular}s"
  end
end
