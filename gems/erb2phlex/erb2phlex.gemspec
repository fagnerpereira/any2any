# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "erb2phlex/version"

Gem::Specification.new do |spec|
  spec.name = "erb2phlex"
  spec.version = Erb2Phlex::VERSION
  spec.authors = ["Contributors"]
  spec.email = ["noreply@any2any.dev"]

  spec.summary = "Convert ERB to PHLEX"
  spec.description = "Specific converter from ERB to PHLEX extracted from any2any."
  spec.homepage = "https://github.com/your-org/any2any"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir.chdir(__dir__) do
    Dir["{bin,lib}/**/*"]
  end

  spec.bindir = "bin"
  spec.executables = ["erb2phlex"]
  spec.require_paths = ["lib"]

  spec.add_dependency "diff-lcs"\n  spec.add_dependency "herb"\n  spec.add_dependency "parser"\n  spec.add_dependency "pastel"\n  spec.add_dependency "thor"\n  spec.add_dependency "tty-prompt"
end
