# erb2haml

A specific converter from ERB to HAML, extracted from the any2any project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'erb2haml'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install erb2haml

## Usage

You can use it via the command line:

```bash
erb2haml input.erb output.haml
```

Or in your Ruby code:

```ruby
require 'erb2haml'

result = Erb2haml.convert(File.read('input.erb'))
puts result[:output]
```

## License

MIT
