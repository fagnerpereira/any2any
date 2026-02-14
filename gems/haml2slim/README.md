# haml2slim

A specific converter from HAML to SLIM, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'haml2slim'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install haml2slim

## Usage

You can use it via the command line:

```bash
haml2slim input.haml output.slim
```

Or in your Ruby code:

```ruby
require 'haml2slim'

result = Haml2slim.convert(File.read('input.haml'))
puts result[:output]
```

## License

MIT
