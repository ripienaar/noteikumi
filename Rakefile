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

task :test => :spec