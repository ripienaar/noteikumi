require "spec_helper"
require "noteikumi"

describe Noteikumi::RuleExecutionScope do
  let(:logger) { stub(:debug => nil, :info => nil, :warn => nil, :error => nil) }
  let(:engine) { Noteikumi::Engine.new("spec/fixtures", logger) }
  let(:state) { engine.create_state }
  let(:rule) { engine.rules_collection.rules.first }
  let(:scope) { Noteikumi::RuleExecutionScope.new(rule) }

  before(:each) do
    rule.assign_state(state)
  end

  describe "#run" do
    it "should run the rule run logic" do
      check = stub(:y)
      rule.run { check.y }
      scope.run
    end
  end

  describe "#initialize" do
    it "should make the state, rule and logger available" do
      expect(scope.rule).to be(rule)
      expect(scope.state).to be(state)
      expect(scope.logger).to be(logger)
    end
  end
end
