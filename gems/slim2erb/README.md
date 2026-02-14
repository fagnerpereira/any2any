# slim2erb

A specific converter from SLIM to ERB, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slim2erb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install slim2erb

## Usage

You can use it via the command line:

```bash
slim2erb input.slim output.erb
```

Or in your Ruby code:

```ruby
require 'slim2erb'

result = Slim2erb.convert(File.read('input.slim'))
puts result[:output]
```

## License

MIT
