# erb2phlex

A specific converter from ERB to PHLEX, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'erb2phlex'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install erb2phlex

## Usage

You can use it via the command line:

```bash
erb2phlex input.erb output.phlex
```

Or in your Ruby code:

```ruby
require 'erb2phlex'

result = Erb2phlex.convert(File.read('input.erb'))
puts result[:output]
```

## License

MIT
