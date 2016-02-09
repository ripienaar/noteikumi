class Noteikumi
  class RuleConditionValidator
    def initialize(rule)
      @__rule = rule
    end

    # Checks if this is the first time the rule is being ran
    #
    # @return [Boolean]
    def first_run?
      @__rule.run_count == 0
    end

    # Checks if the state had any past failures
    #
    # @return [Boolean]
    def state_had_failures?
      @__rule.state.had_failures?
    end

    # Checks if a rule with a specific name acted on the state
    #
    # @param rule [Symbol,Rule]
    # @return [Boolean]
    def state_processed_by?(rule)
      @__rule.state.processed_by?(rule)
    end

    # Runs the rules run condition
    #
    # @api private
    # @return [Boolean]
    def __should_run?
      instance_eval(&@__rule.run_condition)
    end

    # Determines if the rule has a condition by name
    #
    # @api private
    # @param condition [Symbol] the condition name
    # @return [Boolean]
    def __known_condition?(condition)
      @__rule.has_condition?(condition)
    end

    # Retrieves a named condition from the rule
    #
    # @api private
    # @param condition [Symbol] the condition name
    # @return [Proc,nil]
    def __condition(condition)
      @__rule.conditions[condition]
    end

    # Evaluate a named condition
    #
    # @api private
    # @param condition [Symbol] the condition name
    # @param args [Array<Object>] arguments to pass to the condition
    # @return [Boolean]
    def __evaluate_condition(condition, *args)
      result = !!__condition(condition).call(*args)
      @__rule.logger.debug("Condition %s returned %s on %s" % [condition, result.inspect, @__rule])
      result
    end

    # Provide method access to named based conditions
    #
    # @see {__evaluate_condition}
    def method_missing(method, *args, &blk)
      if __known_condition?(method)
        __evaluate_condition(method, *args)
      else
        super
      end
    end
  end
end
