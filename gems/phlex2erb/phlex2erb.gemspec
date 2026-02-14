# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "phlex2erb/version"

Gem::Specification.new do |spec|
  spec.name = "phlex2erb"
  spec.version = Phlex2Erb::VERSION
  spec.authors = ["Contributors"]
  spec.email = ["noreply@any2any.dev"]

  spec.summary = "Convert PHLEX to ERB"
  spec.description = "Specific converter from PHLEX to ERB extracted from any2any."
  spec.homepage = "https://github.com/your-org/any2any"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir.chdir(__dir__) do
    Dir["{bin,lib}/**/*"]
  end

  spec.bindir = "bin"
  spec.executables = ["phlex2erb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "diff-lcs"\n  spec.add_dependency "herb"\n  spec.add_dependency "parser"\n  spec.add_dependency "pastel"\n  spec.add_dependency "thor"\n  spec.add_dependency "tty-prompt"
end
