# haml2erb

A specific converter from HAML to ERB, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'haml2erb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install haml2erb

## Usage

You can use it via the command line:

```bash
haml2erb input.haml output.erb
```

Or in your Ruby code:

```ruby
require 'haml2erb'

result = Haml2erb.convert(File.read('input.haml'))
puts result[:output]
```

## License

MIT
