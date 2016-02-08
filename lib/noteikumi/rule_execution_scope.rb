class Noteikumi
  class RuleExecutionScope
    attr_reader :rule, :state, :logger

    def initialize(rule)
      @rule = rule
      @state = rule.state
      @logger = rule.logger
    end

    def run
      @rule.run_logic.call
    end
  end
end
