# phlex2slim

A specific converter from PHLEX to SLIM, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phlex2slim'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install phlex2slim

## Usage

You can use it via the command line:

```bash
phlex2slim input.phlex output.slim
```

Or in your Ruby code:

```ruby
require 'phlex2slim'

result = Phlex2slim.convert(File.read('input.phlex'))
puts result[:output]
```

## License

MIT
