# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "phlex2slim/version"

Gem::Specification.new do |spec|
  spec.name = "phlex2slim"
  spec.version = Phlex2Slim::VERSION
  spec.authors = ["Contributors"]
  spec.email = ["noreply@any2any.dev"]

  spec.summary = "Convert PHLEX to SLIM"
  spec.description = "Specific converter from PHLEX to SLIM extracted from any2any."
  spec.homepage = "https://github.com/your-org/any2any"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir.chdir(__dir__) do
    Dir["{bin,lib}/**/*"]
  end

  spec.bindir = "bin"
  spec.executables = ["phlex2slim"]
  spec.require_paths = ["lib"]

  spec.add_dependency "diff-lcs"\n  spec.add_dependency "parser"\n  spec.add_dependency "pastel"\n  spec.add_dependency "slim"\n  spec.add_dependency "temple"\n  spec.add_dependency "thor"\n  spec.add_dependency "tty-prompt"
end
