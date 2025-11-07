# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'any2any/version'

Gem::Specification.new do |spec|
  spec.name          = 'any2any'
  spec.version       = Any2Any::VERSION
  spec.authors       = ['Contributors']
  spec.email         = ['noreply@any2any.dev']

  spec.summary       = 'Direct, efficient converter between ERB, Slim, HAML, and Phlex templates'
  spec.description   = 'any2any eliminates the need for multi-step conversions (e.g., ERB → HAML → Slim). It uses AST-to-AST transformations via a unified Intermediate Representation for much faster, more accurate conversions. Now with Phlex support!'
  spec.homepage      = 'https://github.com/your-org/any2any'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.0'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Core dependencies
  spec.add_dependency 'slim', '~> 5.2'
  spec.add_dependency 'haml', '~> 6.0'
  spec.add_dependency 'temple', '~> 0.10'
  spec.add_dependency 'parser', '~> 3.3'
  spec.add_dependency 'herb', '~> 0.7'
  spec.add_dependency 'thor', '~> 1.3'
  spec.add_dependency 'pastel', '~> 0.8'
  spec.add_dependency 'tty-prompt', '~> 0.23'
  spec.add_dependency 'diff-lcs', '~> 1.5'

  # Development dependencies
  spec.add_development_dependency 'minitest', '~> 5.20'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'benchmark-ips'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'debug'
end
