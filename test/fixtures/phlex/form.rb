class Form < Phlex::HTML
  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::Label
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::TextField

  attr_accessor :book

  def initialize(book:)
    @book = book
  end

  def view_template
    form_with(model: book, class: "contents") do |form|
      if book.errors.any?
        div(
          id: "error_explanation",
          class: "bg-red-50 text-red-500 px-3 py-2 font-medium rounded-md mt-3"
        ) do
          h2 do
            pluralize(book.errors.count, "error")
            plain " prohibited this book from being saved:"
          end
          ul(class: "list-disc ml-6") do
            book.errors.each { |error| li { error.full_message } }
          end
        end
      end

      div(class: "my-5") do
        plain form.label :name
        plain form.text_field :name,
          class: [
            "block shadow-sm rounded-md border px-3 py-2 mt-2 w-full",
            {
              "border-gray-400 focus:outline-blue-600":
                book.errors[:name].none?,
              "border-red-400 focus:outline-red-600":
                book.errors[:name].any?
            }
          ]
      end

      div(class: "my-5") do
        plain form.label :author
        plain form.text_field :author,
          class: [
            "block shadow-sm rounded-md border px-3 py-2 mt-2 w-full",
            {
              "border-gray-400 focus:outline-blue-600":
                book.errors[:author].none?,
              "border-red-400 focus:outline-red-600":
                book.errors[:author].any?
            }
          ]
      end

      div(class: "inline") do
        plain form.submit class:
                            "w-full sm:w-auto rounded-md px-3.5 py-2.5 bg-blue-600 hover:bg-blue-500 text-white inline-block font-medium cursor-pointer"
      end
    end
  end
end
