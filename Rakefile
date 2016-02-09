begin
  require 'rubygems'
  require 'rspec/core/rake_task'
rescue LoadError
end

if defined?(RSpec::Core::RakeTask)
  desc "Run all specs"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/**/*_spec.rb'
  end
  task :test => :spec
end

desc "Check Ruby style using Rubocop"
task :rubocop do
  sh "bundle exec rubocop -f progress -f offenses lib spec examples"
end

task :default => [:spec, :rubocop]

namespace :doc do
  desc "Serve YARD documentation on %s:%d" % [ENV.fetch("YARD_BIND", "127.0.0.1"), ENV.fetch("YARD_PORT", "9292")]
  task :serve do
    system("yard server --reload --bind %s --port %d" % [ENV.fetch("YARD_BIND", "127.0.0.1"), ENV.fetch("YARD_PORT", "9292")])
  end

  desc "Generate documentatin into the %s" % ENV.fetch("YARD_OUT", "doc")
  task :yard do
    system("yard doc --output-dir %s" % ENV.fetch("YARD_OUT", "doc"))
  end
end
