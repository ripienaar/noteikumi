require 'spec_helper'
require 'noteikumi'

describe Noteikumi::State do
  let(:logger) { stub(:debug => nil, :info => nil, :warn => nil) }
  let(:engine) { stub }
  let(:state) { Noteikumi::State.new(engine, logger) }

  describe "#get" do
    it "should get the item" do
      state.add(:rspec, 1)
      expect(state.get(:rspec)).to eq(1)
      expect(state.get(:fail)).to eq(nil)
    end
  end

  describe "#add" do
    it "should fail when immutable" do
      state.mutable = false
      expect { state.add(:rspec, 1) }.to raise_error("State is not mustable")
    end

    it "should add the item" do
      expect(state.add(:rspec, 1)).to eq(1)
      expect(state.get(:rspec)). to eq(1)
    end

    it "should fail when previously added" do
      state.add(:rspec, 1)
      expect { state.add(:rspec, 1) }.to raise_error("Already have item rspec")
    end
  end

  describe "#delete" do
    it "should fail when immutable" do
      state.mutable = false
      expect { state.delete(:rspec) }.to raise_error("State is not mustable")
    end

    it "should delete the item" do
      state.add(:rspec, 1)

      expect(state.delete(:rspec)).to be(1)
      expect(state.has?(:rspec)).to be(false)
    end
  end

  describe "#set" do
    it "should fail when immutable" do
      state.set(:rspec, 1)
      state.mutable = false
      expect{ state.add(:rspec, 1) }.to raise_error("State is not mustable")
    end

    it "should set the value" do
      expect(state.add(:rspec, 1)).to be(1)
      expect(state[:rspec]).to be(1)
    end
  end

  describe "#include?" do
    it "should check for included items" do
      state.add(:rspec, 1)
      expect(state.include?(:rspec)).to be(true)
      expect(state.include?(:bob)).to be(false)
    end
  end

  describe "#record_rule" do
    it "should record the rule" do
      state.record_rule(rule = stub)
      expect(state.processed_by).to eq([rule])
    end
  end

  describe "#mutable?" do
    it "should be mutable by default" do
      expect(state.mutable?).to be(true)
    end

    it "should support being immutable" do
      state.mutable = false
      expect(state.mutable?).to be(false)
    end
  end

  describe "#has_item_of_type?" do
    it "should correctly report items" do
      state.add(:rspec1, "rspec")
      state.add(:rspec2, 1)
      state.add(:rspec3, {})

      expect(state.has_item_of_type?(String)).to be(true)
      expect(state.has_item_of_type?(Hash)).to be(true)
      expect(state.has_item_of_type?(Integer)).to be(true)
      expect(state.has_item_of_type?(Time)).to be(false)
    end
  end

  describe "#items_by_type" do
    it "should find items of the matching type" do
      state.add(:rspec1, "rspec")
      state.add(:rspec2, 1)
      state.add(:rspec3, {})

      expect(state.items_by_type(String)).to eq([:rspec1, "rspec"])
      expect(state.items_by_type(Hash)).to eq([:rspec3, {}])
      expect(state.items_by_type(Integer)).to eq([:rspec2, 1])
      expect(state.items_by_type(Time)).to eq([])
    end
  end

  describe "#had_failures?" do
    it "should detect no failures" do
      state.add_result(stub(:error? => false))
      state.add_result(stub(:error? => false))

      expect(state.had_failures?).to be(false)
    end

    it "should detect failures" do
      state.add_result(stub(:error? => false))
      state.add_result(stub(:error? => true))
      state.add_result(stub(:error? => false))

      expect(state.had_failures?).to be(true)
    end
  end

  describe "#add_result" do
    it "should add the result" do
      state.add_result(:rspec)
      expect(state.results).to include(:rspec)
    end
  end

  describe "#each_result" do
    it "should yield the results" do
      state.results << r1 = stub
      state.results << r2 = stub

      expect{|b| state.each_result(&b)}.to yield_successive_args(r1, r2)

    end
  end
  describe "#initialize" do
    it "should store the engine" do
      expect(state.engine).to eq(engine)
    end
  end
end
