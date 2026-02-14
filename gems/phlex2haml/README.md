# phlex2haml

A specific converter from PHLEX to HAML, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'phlex2haml'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install phlex2haml

## Usage

You can use it via the command line:

```bash
phlex2haml input.phlex output.haml
```

Or in your Ruby code:

```ruby
require 'phlex2haml'

result = Phlex2haml.convert(File.read('input.phlex'))
puts result[:output]
```

## License

MIT
