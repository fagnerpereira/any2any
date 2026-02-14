# slim2phlex

A specific converter from SLIM to PHLEX, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slim2phlex'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install slim2phlex

## Usage

You can use it via the command line:

```bash
slim2phlex input.slim output.phlex
```

Or in your Ruby code:

```ruby
require 'slim2phlex'

result = Slim2phlex.convert(File.read('input.slim'))
puts result[:output]
```

## License

MIT
