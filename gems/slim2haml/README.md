# slim2haml

A specific converter from SLIM to HAML, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'slim2haml'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install slim2haml

## Usage

You can use it via the command line:

```bash
slim2haml input.slim output.haml
```

Or in your Ruby code:

```ruby
require 'slim2haml'

result = Slim2haml.convert(File.read('input.slim'))
puts result[:output]
```

## License

MIT
