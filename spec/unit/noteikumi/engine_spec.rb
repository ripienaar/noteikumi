require "spec_helper"
require "noteikumi"

describe Noteikumi::Engine do
  let(:logger) { stub(:debug => nil, :info => nil, :warn => nil) }
  let(:engine) { Noteikumi::Engine.new("spec/fixtures", logger) }
  let(:state) { engine.create_state }
  let(:rules) { mock }

  describe "#rules_collection" do
    it "should create new collections and store it" do
      collection = engine.rules_collection
      expect(collection).to be_a(Noteikumi::Rules)
      expect(engine.rules_collection).to be(collection)
    end
  end

  describe "#each_rule" do
    it "should itterate all the rules in the collection" do
      expect {|b| engine.each_rule(&b)}.to yield_successive_args(*engine.rules_collection.rules)
    end
  end

  describe "#create_state" do
    it "should make a new state" do
      state = engine.create_state

      expect(state).to be_a(Noteikumi::State)
      expect(state.engine).to be(engine)
      expect(state.logger).to be(logger)
    end
  end

  describe "#process_state" do
    it "should fail when there are no rules" do
      engine.rules_collection.rules.clear

      expect { engine.process_state(state) }.to raise_error(/No rules have been loaded into engine/)
    end

    it "should run all priority sorted rules and return the results" do
      engine.rules_collection.expects(:by_priority).returns([r1 = mock, r2 = mock])

      state.expects(:process_rule).with(r1)
      state.expects(:process_rule).with(r2)

      expect(engine.process_state(state)).to eq(state.results)
    end
  end

  describe "#initialize" do
    it "should load the rules from disk" do
      Noteikumi::Engine.any_instance.stubs(:rules_collection).returns(rules)

      rules.expects(:load_rules)

      Noteikumi::Engine.new("spec/fixtures", logger)
    end
  end
end
