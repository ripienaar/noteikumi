dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, "lib")

require "mocha/api"
gem "rspec", ">=2.0.0"
require "rspec/expectations"

RSpec.configure do |config|
  config.mock_framework = :mocha
end
