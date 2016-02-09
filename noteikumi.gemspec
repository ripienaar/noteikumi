$LOAD_PATH << File.expand_path("../lib", __FILE__)

require 'noteikumi/version'

Gem::Specification.new do |spec|
  spec.name = "noteikumi"
  spec.version = Noteikumi::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.summary = "noteikumi"
  spec.description = "description: Light weight Rule Engine"
  spec.licenses = ["Apache-2"]

  spec.files = Dir["lib/**/*.rb", "Gemfile"]
  spec.executables = []

  spec.require_path = "lib"

  spec.author = "R.I.Pienaar"
  spec.email = "rip@devco.net"
  spec.homepage = "http://devco.net/"
end
