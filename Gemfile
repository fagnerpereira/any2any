# frozen_string_literal: true

source "https://rubygems.org"

# Core dependencies for parsing and generation
gem 'slim', '~> 5.2'           # Slim parser (Temple S-expressions)
gem 'haml', '~> 6.0'           # HAML parser
gem 'temple', '~> 0.10'        # S-expressions for Slim/HAML
gem 'parser', '~> 3.3'         # Ruby AST for code analysis

# CLI and utilities
gem 'thor', '~> 1.3'           # CLI framework
gem 'pastel', '~> 0.8'         # Colored output
gem 'tty-prompt', '~> 0.23'    # Interactive prompts

# Development and testing
group :development, :test do
  gem 'minitest', '~> 5.20'    # Testing framework
  gem 'minitest-reporters'     # Better test output
  gem 'simplecov'              # Code coverage
  gem 'benchmark-ips'          # Performance benchmarks
  gem 'debug'                  # Debugger
  gem 'rake', '~> 13.0'        # Task runner
end
