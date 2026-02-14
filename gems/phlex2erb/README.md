# phlex2erb

A specific converter from PHLEX to ERB, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phlex2erb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install phlex2erb

## Usage

You can use it via the command line:

```bash
phlex2erb input.phlex output.erb
```

Or in your Ruby code:

```ruby
require 'phlex2erb'

result = Phlex2erb.convert(File.read('input.phlex'))
puts result[:output]
```

## License

MIT
