require "spec_helper"
require "noteikumi"

describe Noteikumi::Rules do
  let(:logger) { stub(:debug => nil, :info => nil, :warn => nil) }
  let(:rules) { Noteikumi::Rules.new("spec/fixtures", logger) }

  describe "#rule_names" do
    it "should get the right names" do
      expect(rules.rule_names).to eq([])
      rules.load_rules
      expect(rules.rule_names).to eq([:rspec])
    end
  end

  describe "#by_priority" do
    it "should find the rules by priority" do
      rules << stub(:priority => 30)
      rules << stub(:priority => 20)
      rules << stub(:priority => 10)

      expect(rules.by_priority.map(&:priority)).to eq([10, 20, 30])
    end
  end

  describe "#find_rules" do
    it "should find rules in the provided dir" do
      expect(rules.find_rules("spec/fixtures")).to eq(["sample_rule.rb"])
      expect(rules.find_rules("/nonexisting")).to eq([])
    end
  end

  describe "#load_rules" do
    it "should look in each directory and load all files" do
      rules.load_rules
      expect(rules.rule_names).to include(:rspec)
    end

    it "should prevent duplicates" do
      rules.load_rules
      expect { rules.load_rules }.to raise_error("Already have a rule called rspec, cannot load another")
    end
  end

  describe "#load_rule" do
    it "should read the file and create a rule" do
      rule = rules.load_rule("spec/fixtures/sample_rule.rb")

      expect(rule.file).to eq("spec/fixtures/sample_rule.rb")
    end
  end

  describe "#<<" do
    it "should append to the rule collection" do
      expect(rules.rules).to eq([])
      rules << 1
      expect(rules.rules).to eq([1])
    end
  end

  describe "#select" do
    it "should yield all the rules" do
      rules << r1 = stub(:rspec => 1)
      rules << r2 = stub(:rspec => 1)
      rules << stub(:rspec => 0)

      expect(rules.select {|r| r.rspec == 1}).to eq([r1, r2])
    end
  end

  describe "#size" do
    it "should get the right count" do
      expect(rules.size).to be(0)
      rules << 1
      rules << 2
      expect(rules.size).to be(2)
    end
  end
end
