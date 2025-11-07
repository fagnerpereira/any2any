# frozen_string_literal: true

require 'parser/current'

module Any2Any
  module Parsers
    # Phlex to IR parser using Ruby Parser gem
    class PhlexParser < BaseParser
      def parse(source)
        begin
          # Parse Ruby code into AST
          buffer = Parser::Source::Buffer.new('(phlex)', source: source)
          ast = Parser::CurrentRuby.new.parse(buffer)

          # Find the view_template method
          view_template_method = find_view_template_method(ast)
          raise ParseError, "No view_template method found in Phlex component" unless view_template_method

          # Transform the method body to IR
          transform_phlex_ast_to_ir(view_template_method)
        rescue Parser::SyntaxError => e
          raise ParseError, "Failed to parse Phlex: #{e.message}"
        rescue ParseError => e
          raise e
        rescue => e
          raise ParseError, "Failed to parse Phlex: #{e.message}"
        end
      end

      private

      def find_view_template_method(ast)
        return nil unless ast

        # Look for def view_template ... end
        if ast.type == :def && ast.children[0] == :view_template
          return ast.children[2] # Return the method body
        end

        # Recursively search in children
        ast.children.each do |child|
          next unless child.is_a?(Parser::AST::Node)
          result = find_view_template_method(child)
          return result if result
        end

        nil
      end

      def transform_phlex_ast_to_ir(node)
        return IR::Template.new(children: []) if node.nil?

        case node.type
        when :begin
          # Multiple statements - map each to IR
          children = node.children.map { |child| transform_node(child) }.compact.flatten
          IR::Template.new(children: children)
        else
          # Single statement
          child = transform_node(node)
          IR::Template.new(children: child ? Array(child) : [])
        end
      end

      def transform_node(node)
        return nil unless node.is_a?(Parser::AST::Node)

        case node.type
        when :block
          # Method call with block: div do ... end
          transform_block_call(node)
        when :send
          # Method call without block or plain/text calls
          transform_send(node)
        when :str
          # String literal
          IR::StaticContent.new(text: node.children[0])
        when :lvar
          # Local variable reference
          IR::Expression.new(code: node.children[0].to_s, escaped: true)
        when :ivar
          # Instance variable reference
          IR::Expression.new(code: node.children[0].to_s, escaped: true)
        when :if
          # Conditional
          transform_conditional(node)
        when :begin
          # Multiple statements
          node.children.map { |child| transform_node(child) }.compact
        else
          # For unknown types, try to convert to expression
          nil
        end
      end

      def transform_block_call(node)
        # node structure: (:block, method_call, args, body)
        method_call = node.children[0]
        block_args = node.children[1]
        block_body = node.children[2]

        return nil unless method_call.type == :send

        receiver = method_call.children[0]
        method_name = method_call.children[1]
        method_args = method_call.children[2..-1]

        # Check if it's an HTML element method (div, p, span, etc.)
        if html_element?(method_name)
          # Extract attributes from method arguments
          attributes = extract_attributes_from_args(method_args)

          # Transform block body to children
          children = transform_block_body(block_body)

          IR::Element.new(
            tag_name: method_name.to_s,
            attributes: attributes,
            children: children,
            self_closing: false
          )
        elsif method_name == :each
          # Loop: collection.each do |var| ... end
          transform_loop(receiver, block_args, block_body)
        else
          # Generic block - treat as Block node
          code = unparse_node(method_call)
          children = transform_block_body(block_body)

          # If it's just a code block without special meaning, return as block
          IR::Block.new(code: code, children: children)
        end
      end

      def transform_send(node)
        receiver = node.children[0]
        method_name = node.children[1]
        args = node.children[2..-1]

        case method_name
        when :plain, :text
          # plain "text" or text "text"
          if args.first && args.first.type == :str
            IR::StaticContent.new(text: args.first.children[0])
          elsif args.first
            # Dynamic content - check if it's a variable or expression
            code = unparse_node(args.first)
            IR::Expression.new(code: code, escaped: true)
          end
        when :raw
          # raw "text" - unescaped content
          if args.first
            code = args.first.type == :str ? args.first.children[0] : unparse_node(args.first)
            IR::Expression.new(code: code, escaped: false)
          end
        when :comment
          # comment "text" or comment { "text" }
          text = if args.first && args.first.type == :str
            args.first.children[0]
          else
            ""
          end
          IR::Comment.new(text: text, html_visible: true)
        when :render
          # render SomeComponent - skip for now
          nil
        else
          # Check if it's a self-closing or regular HTML element
          if html_element?(method_name)
            attributes = extract_attributes_from_args(args)
            self_closing = void_elements.include?(method_name.to_s)

            IR::Element.new(
              tag_name: method_name.to_s,
              attributes: attributes,
              children: [],
              self_closing: self_closing
            )
          else
            # Some other method call - might be a helper, skip
            nil
          end
        end
      end

      def transform_conditional(node)
        condition = node.children[0]
        true_branch = node.children[1]
        false_branch = node.children[2]

        IR::Conditional.new(
          condition: unparse_node(condition),
          true_branch: true_branch ? Array(transform_node(true_branch)).compact.flatten : [],
          false_branch: false_branch ? Array(transform_node(false_branch)).compact.flatten : []
        )
      end

      def transform_loop(receiver, block_args, block_body)
        collection = unparse_node(receiver)

        # Extract variable name from block args
        variable = if block_args && block_args.type == :args && block_args.children.first
          block_args.children.first.children.first.to_s
        else
          'item'
        end

        body = transform_block_body(block_body)

        IR::Loop.new(
          collection: collection,
          variable: variable,
          body: body
        )
      end

      def transform_block_body(body)
        return [] if body.nil?

        if body.type == :begin
          # Multiple statements
          body.children.map { |child| transform_node(child) }.compact.flatten
        else
          # Single statement
          result = transform_node(body)
          result ? (result.is_a?(Array) ? result : [result]) : []
        end
      end

      def extract_attributes_from_args(args)
        attributes = {}

        args.each do |arg|
          if arg.type == :hash
            # Hash of attributes: { class: "foo", id: "bar" }
            arg.children.each do |pair|
              next unless pair.type == :pair
              key = extract_hash_key(pair.children[0])
              value = extract_hash_value(pair.children[1])
              attributes[key] = value if key && value
            end
          elsif arg.type == :str
            # String argument might be shorthand class
            attributes['class'] = arg.children[0]
          end
        end

        attributes
      end

      def extract_hash_key(node)
        case node.type
        when :sym
          node.children[0].to_s
        when :str
          node.children[0]
        else
          nil
        end
      end

      def extract_hash_value(node)
        case node.type
        when :str
          node.children[0]
        when :sym
          node.children[0].to_s
        when :true
          'true'
        when :false
          'false'
        when :nil
          'nil'
        else
          # For complex expressions, unparse them
          unparse_node(node)
        end
      end

      def unparse_node(node)
        return '' if node.nil?

        # Convert AST node back to Ruby code
        case node.type
        when :str
          node.children[0].to_s
        when :int
          node.children[0].to_s
        when :lvar, :ivar
          node.children[0].to_s
        when :send
          receiver = node.children[0]
          method = node.children[1]
          args = node.children[2..-1]

          receiver_str = receiver ? "#{unparse_node(receiver)}." : ''
          args_str = args.empty? ? '' : "(#{args.map { |a| unparse_node(a) }.join(', ')})"
          "#{receiver_str}#{method}#{args_str}"
        when :const
          scope = node.children[0]
          name = node.children[1]
          scope ? "#{unparse_node(scope)}::#{name}" : name.to_s
        when :begin
          # Multiple expressions
          node.children.map { |c| unparse_node(c) }.join('; ')
        else
          # Fallback
          node.children.select { |c| c.is_a?(Parser::AST::Node) || c.is_a?(Symbol) }
              .map { |c| c.is_a?(Parser::AST::Node) ? unparse_node(c) : c.to_s }
              .join('.')
        end
      rescue => e
        # If unparsing fails, return a placeholder
        "#{node.type}"
      end

      def html_element?(method_name)
        # Common HTML elements that Phlex supports
        html_elements = %i[
          a abbr address article aside audio b bdi bdo blockquote body br button
          canvas caption cite code col colgroup data datalist dd del details dfn
          dialog div dl dt em embed fieldset figcaption figure footer form h1 h2
          h3 h4 h5 h6 head header hr html i iframe img input ins kbd label legend
          li link main map mark meta meter nav noscript object ol optgroup option
          output p param picture pre progress q rp rt ruby s samp script section
          select small source span strong style sub summary sup table tbody td
          template textarea tfoot th thead time title tr track u ul var video wbr
        ]

        html_elements.include?(method_name)
      end
    end
  end
end
