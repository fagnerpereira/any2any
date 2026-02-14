# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "haml2erb/version"

Gem::Specification.new do |spec|
  spec.name = "haml2erb"
  spec.version = Haml2Erb::VERSION
  spec.authors = ["Contributors"]
  spec.email = ["noreply@any2any.dev"]

  spec.summary = "Convert HAML to ERB"
  spec.description = "Specific converter from HAML to ERB extracted from any2any."
  spec.homepage = "https://github.com/your-org/any2any"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir.chdir(__dir__) do
    Dir["{bin,lib}/**/*"]
  end

  spec.bindir = "bin"
  spec.executables = ["haml2erb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "diff-lcs"\n  spec.add_dependency "haml"\n  spec.add_dependency "herb"\n  spec.add_dependency "pastel"\n  spec.add_dependency "temple"\n  spec.add_dependency "thor"\n  spec.add_dependency "tty-prompt"
end
