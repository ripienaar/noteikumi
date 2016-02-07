require "spec_helper"
require "noteikumi"

describe Noteikumi::Rule do
  let(:logger) { stub(:debug => nil, :info => nil, :warn => nil) }
  let(:rule) { Noteikumi::Rule.new(:rspec, :logger => logger) }

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
      block = lambda { :rspec }
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

  describe "#priority=" do
    it "should set the priority" do
      rule.priority = 10
      expect(rule.priority).to be(10)

      rule.priority = "11"
      expect(rule.priority).to be(11)
    end
  end
  describe "#run" do
    it "should require a block" do
      expect { rule.run }.to raise_error("A block is needed to run")
    end

    it "should save the block" do
      block = lambda { :rspec }
      rule.run(&block)
      expect(rule.run_logic).to be(block)
    end
  end

  describe "#run_when" do
    it "should require a block" do
      expect { rule.run_when }.to raise_error("A block is needed to evaluate for run_when")
    end

    it "should save the block" do
      block = lambda { :rspec }
      rule.run_when(&block)
      expect(rule.run_condition).to be(block)
    end
  end
end
