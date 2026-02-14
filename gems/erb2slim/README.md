# erb2slim

A specific converter from ERB to SLIM, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'erb2slim'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install erb2slim

## Usage

You can use it via the command line:

```bash
erb2slim input.erb output.slim
```

Or in your Ruby code:

```ruby
require 'erb2slim'

result = Erb2slim.convert(File.read('input.erb'))
puts result[:output]
```

## License

MIT
