require "spec_helper"
require "noteikumi"

describe Noteikumi::RuleConditionValidator do
  let(:logger) { stub(:debug => nil, :info => nil, :warn => nil, :error => nil) }
  let(:engine) { Noteikumi::Engine.new("spec/fixtures", logger) }
  let(:state) { engine.create_state }
  let(:rule) { engine.rules_collection.rules.first }
  let(:validator) { Noteikumi::RuleConditionValidator.new(rule) }

  before(:each) do
    rule.assign_state(state)
  end

  describe "#method_missing" do
    it "should evaluate the right condition" do
      check = mock(:x => true)
      rule.condition(:rspec) { check.x }
      expect(validator.rspec).to be(true)
    end

    it "should support arguments" do
      check = mock
      check.expects(:x).with(:y).returns(true)
      rule.condition(:rspec) {|arg| check.x(arg) }
      expect(validator.rspec(:y)).to be(true)
    end
  end

  describe "#__evaluate_condition" do
    it "should evaluate the right condition" do
      check = mock(:x => true)
      rule.condition(:rspec) { check.x }
      expect(validator.__evaluate_condition(:rspec)).to be(true)
    end
  end

  describe "#__condition" do
    it "should retrieve the condition" do
      expect(validator.__condition(:one)).to be(rule.conditions[:one])
    end
  end

  describe "#__known_condition?" do
    it "should check if the rule has the condition" do
      expect(validator.__known_condition?(:one)).to be(true)
      expect(validator.__known_condition?(:notexisting)).to be(false)
    end
  end

  describe "#__should_run?" do
    it "should run the rule run_condition" do
      check = mock(:x => true)
      rule.run_when { check.x }
      expect(validator.__should_run?).to be(true)
    end
  end

  describe "#state_had_failures?" do
    it "should get the state failure status" do
      state.expects(:had_failures?).returns(true)
      expect(validator.state_had_failures?).to be(true)
    end
  end

  describe "#first_run?" do
    it "should check the rule run count" do
      rule.expects(:run_count).returns(0)
      expect(validator.first_run?).to be(true)

      rule.expects(:run_count).returns(1)
      expect(validator.first_run?).to be(false)
    end
  end
end
