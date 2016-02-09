class Noteikumi
  # Represents the result of running a specific rule
  class Result
    # The time it took for the rule to be processed
    # @return [Float]
    attr_reader :run_time

    # The time the rule started
    # @return [Time,nil]
    attr_reader :start_time

    # The time the rule ended
    # @return [Time,nil]
    attr_reader :end_time

    # Any output produced by the rule
    attr_reader :output

    # The rule the result relates to
    # @return [Rule,nil]
    attr_reader :rule

    # The exception a rule raised
    # @return [Exception,nil]
    attr_accessor :exception

    # Any output returned from the rule run block
    # @return [Object,nil]
    attr_accessor :output

    # Creates a result for a rule
    #
    # @param rule [Rule]
    # @return [Result]
    def initialize(rule)
      @rule = rule
      @start_time = nil
      @end_time = nil
      @run_time = nil
      @exception = nil
      @output = nil
      @ran = false
    end

    # The rule name
    #
    # @return [String,Symbol]
    def name
      @rule.name
    end

    # If the result has an exception
    #
    # @return [Boolean]
    def error?
      !!exception
    end

    # Determines if this rule ran
    #
    # @return [Boolean]
    def ran?
      @ran
    end

    # Records the start time for the rule process
    #
    # @return [Time]
    def start_processing
      @ran = true
      @start_time = Time.now
    end

    # Records that processing have ended
    #
    # @return [Time]
    def stop_processing
      @end_time = Time.now
      @run_time = @end_time - @start_time
    end

    # :nodoc:
    # @return [String]
    def inspect
      "#<%s:%s rule: %s ran: %s error: %s>" % [self.class, object_id, name, ran?, error?]
    end
  end
end
