require "spec_helper"
require "noteikumi"

describe Noteikumi::Result do
  let(:rule) { mock(:name => :rspec) }
  let(:result) { Noteikumi::Result.new(rule) }

  describe "#stop_processing" do
    it "should set the start time" do
      expect(result.end_time).to be(nil)
      expect(result.run_time).to be(nil)
      result.start_processing
      result.stop_processing
      expect(result.end_time).to be_a(Time)
      expect(result.run_time).to be_a(Float)
    end
  end

  describe "#start_processing" do
    it "should set the start time" do
      expect(result.start_time).to be(nil)
      result.start_processing
      expect(result.start_time).to be_a(Time)
    end
  end

  describe "#error?" do
    it "should determine if a error was logged" do
      expect(result.error?).to be(false)

      result.exception = Exception.new

      expect(result.error?).to be(true)
    end
  end
end
