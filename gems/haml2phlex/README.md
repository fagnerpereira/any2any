# haml2phlex

A specific converter from HAML to PHLEX, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'haml2phlex'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install haml2phlex

## Usage

You can use it via the command line:

```bash
haml2phlex input.haml output.phlex
```

Or in your Ruby code:

```ruby
require 'haml2phlex'

result = Haml2phlex.convert(File.read('input.haml'))
puts result[:output]
```

## License

MIT
