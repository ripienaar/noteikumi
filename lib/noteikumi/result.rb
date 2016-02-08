class Noteikumi
  class Result
    attr_reader :name, :run_time, :start_time, :end_time, :output, :rule
    attr_accessor :exception, :output

    def initialize(rule)
      @rule = rule
      @start_time = nil
      @end_time = nil
      @run_time = nil
      @exception = nil
      @output = nil
      @name = rule.name
    end

    # If the result has an exception
    #
    # @return [Boolean]
    def error?
      !!exception
    end

    # Records the start time for the rule process
    #
    # @return [Time]
    def start_processing
      @start_time = Time.now
    end

    # Records that processing have ended
    #
    # @return [Time]
    def stop_processing
      @end_time = Time.now
      @run_time = @end_time - @start_time
    end
  end
end
