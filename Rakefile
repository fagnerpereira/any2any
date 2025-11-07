require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = [
    'test/generators/test_slim_generator.rb',
    'test/integration/test_conversions.rb',
    'test/ir/test_nodes.rb',
    'test/parsers/test_erb_parser.rb',
    'test/parsers/test_haml_parser.rb',
    'test/parsers/test_slim_parser.rb'
  ]
  t.verbose = true
end

task default: :test
