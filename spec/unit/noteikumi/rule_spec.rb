require "spec_helper"
require "noteikumi"

describe Noteikumi::Rule do
  let(:logger) { stub(:debug => nil, :info => nil, :warn => nil, :error => nil) }
  let(:engine) { Noteikumi::Engine.new("spec/fixtures", logger) }
  let(:state) { engine.create_state }
  let(:rule) { engine.rules_collection.rules.first }

  before(:each) do
    state[:string] = "hello world"
    state[:number] = 1
  end

  describe "#state_meets_requirements?" do
    it "should check every requirement" do
      state.expects(:meets_requirement?).with([:string, String]).returns([true, "true"])
      state.expects(:meets_requirement?).with([nil, Fixnum]).returns([true, "true"])

      rule.assign_state(state)
      expect(rule.state_meets_requirements?).to be(true)
    end

    it "should handle failure and bail early" do
      state.expects(:meets_requirement?).with([:string, String]).returns([false, "rspec"])
      state.expects(:meets_requirement?).with([nil, Fixnum]).never

      rule.assign_state(state)
      expect(rule.state_meets_requirements?).to be(false)
    end
  end

  describe "#satisfies_run_condition?" do
    it "should check via the rule condition validator" do
      Noteikumi::RuleConditionValidator.any_instance.expects(:__should_run?).returns(true)
      expect(rule.satisfies_run_condition?).to be(true)
    end
  end

  describe "#run_rule_logic" do
    it "should increment count, run the rule and return the output" do
      state[:sleep_time] = 0.001

      expect(rule.run_count).to be(0)
      expect(state.results).to be_empty

      result = rule.process(state)

      expect(rule.run_count).to be(1)
      expect(result.output).to eq("hello world")
      expect(result.exception).to be(nil)
      expect(result.error?).to be(false)
      expect(result.run_time).to be >= 0.001
      expect(result.run_time).to be <= 0.1
    end

    it "should catch errors and store the errors" do
      state[:raise_this] = "expected error"

      result = rule.process(state)

      expect(result.exception).to be_an(StandardError)
      expect(result.error?).to be(true)
    end
  end

  describe "#with_state" do
    it "should store and reset the state" do
      rule.with_state(:rspec) do
        expect(rule.state).to be(:rspec)
      end
      expect(rule.state).to be(nil)
    end
  end

  describe "#assign_state, #reset_state" do
    it "should assign the state" do
      expect(rule.state).to be(nil)
      rule.assign_state(:rspec)
      expect(rule.state).to be(:rspec)
      rule.reset_state
      expect(rule.state).to be(nil)
    end
  end

  describe "#has_condition?" do
    it "should correctly report if a condition is known" do
      rule.condition(:rspec) { true }
      expect(rule.has_condition?(:rspec)).to be(true)
      expect(rule.has_condition?(:missing)).to be(false)
    end
  end

  describe "#requirement" do
    it "should handle type only requirements" do
      rule.requirement(String)
      expect(rule.needs).to include([nil, String])
    end

    it "should handle named type requirements" do
      rule.requirement(:rspec, String)
      expect(rule.needs).to include([:rspec, String])
    end
  end

  describe "#condition" do
    it "should check for duplicates" do
      rule.condition(:rspec) { }
      expect { rule.condition(:rspec) { } }.to raise_error("Duplicate condition name rspec")
    end

    it "should check a block is given" do
      expect { rule.condition(:rspec) }.to raise_error("A block is required for condition rspec")
    end

    it "should store the condition" do
      block = -> { :rspec }
      rule.condition(:rspec, &block)
      expect(rule.conditions[:rspec]).to eq(block)
    end
  end

  describe "#concurrency=" do
    it "should check the concurrency is valid" do
      expect { rule.concurrency = :rspec }.to raise_error("Concurrency has to be one of :safe, :unsafe")
    end

    it "should set the concurrency" do
      rule.concurrency = :safe
      expect(rule.concurrent).to eq(:safe)

      rule.concurrency = :unsafe
      expect(rule.concurrent).to eq(:unsafe)
    end
  end

  describe "#rule_priority" do
    it "should set the priority" do
      rule.rule_priority(10)
      expect(rule.priority).to be(10)

      rule.rule_priority("11")
      expect(rule.priority).to be(11)
    end
  end
  describe "#run" do
    it "should require a block" do
      expect { rule.run }.to raise_error("A block is needed to run")
    end

    it "should save the block" do
      block = -> { :rspec }
      rule.run(&block)
      expect(rule.run_logic).to be(block)
    end
  end

  describe "#run_when" do
    it "should require a block" do
      expect { rule.run_when }.to raise_error("A block is needed to evaluate for run_when")
    end

    it "should save the block" do
      block = -> { :rspec }
      rule.run_when(&block)
      expect(rule.run_condition).to be(block)
    end
  end
end
