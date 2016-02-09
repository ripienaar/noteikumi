class Noteikumi
  # A class that exist to execute the logic of the rule
  # @api private
  class RuleExecutionScope
    # The rule being ran
    # @return [Rule]
    attr_reader :rule

    # The state the rule is processing
    # @return [State]
    attr_reader :state

    # The active logger
    # @return [Logger]
    attr_reader :logger

    # Creates a new scope object
    #
    # @param rule [Rule]
    # @return [RuleExecutionScope
    def initialize(rule)
      @rule = rule
      @state = rule.state
      @logger = rule.logger
    end

    # Runs the rule logic within this scope
    #
    # @return [Object] the output from the rule
    def run
      @rule.run_logic.call
    end
  end
end
