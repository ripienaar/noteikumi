class Noteikumi
  class Rule
    attr_reader :priority, :concurrent, :needs, :conditions, :state
    attr_reader :run_condition, :run_logic, :run_count
    attr_accessor :file, :name, :logger

    # Creates a new rule
    #
    # @param name [String,Symbol] the name of the rule
    # @return [Rule]
    def initialize(name)
      @name = name
      @priority = 50
      @concurrent = :unsafe
      @needs = []
      @conditions = {}
      @state = nil
      @file = "unknown file"
      @run_count = 0

      run_when { true }
      run { raise("No execution logic provided for rule") }
    end

    # Checks if a condition matching the name has been created on the rule
    #
    # @see {#condition}
    # @param condition [Symbol] condition name
    # @return [Boolean]
    def has_condition?(condition)
      @conditions.include?(condition)
    end

    # Assign the provided state to the rule
    #
    # @param state [State] the state to store
    # @return [void]
    def assign_state(state)
      @state = state
    end

    # Resets the state to nil state
    #
    # @return [void]
    def reset_state
      @state = nil
    end

    # Assigns the state, yields to the block and resets it
    #
    # @param state [State] a state to act on
    # @return [Object] the outcome from the block
    def with_state(state)
      assign_state(state)

      yield
    ensure
      reset_state
    end

    # Runs the rule logic
    #
    # Rules are run within an instance of {RuleExecutionScope}
    #
    # @return [Result]
    def run_rule_logic
      @run_count += 1

      result = new_result

      begin
        result.start_processing
        result.output = RuleExecutionScope.new(self).run
      rescue => e
        logger.error("Error during processing of rule: %s: %s: %s" % [self, e.class, e.to_s])
        logger.debug(e.backtrace.join("\n\t"))
        result.exception = e
      ensure
        result.stop_processing
      end

      result
    end

    # Construct a result object for this rule
    #
    # @return [Result]
    def new_result
      Result.new(self)
    end

    # Process a rule after first checking all the requirements are met
    #
    # @param state [State] the state to use as scope
    # @return [Result,nil] nil when the rule never ran due to state checks
    def process(state)
      result = nil

      with_state(state) do
        if state_meets_requirements?
          if satisfies_run_condition?
            logger.debug("Processing rule %s" % self)
            result = run_rule_logic
          else
            logger.debug("Skipping processing rule due to run_when block returning false on %s" % self)
          end
        else
          logger.debug("Skipping processing rule %s due to state check failing" % self)
        end
      end

      result
    end

    # Determines if the run_when block is satisfied
    #
    # @return [Boolean]
    def satisfies_run_condition?
      validator = RuleConditionValidator.new(self)
      validator.__should_run?
    end

    # Checks every requirement against the state
    #
    # @return [Boolean]
    def state_meets_requirements?
      @needs.each do |requirement|
        valid, reason = state.meets_requirement?(requirement)

        unless valid
          logger.debug("State does not meet the requirements %s: %s" % [self, reason])
          return false
        end
      end

      true
    end

    def to_s
      "#<%s:%s run_count: %d priority: %d name: %s @ %s>" % [self.class, object_id, run_count, priority, name, file]
    end

    def run_when(&blk)
      raise("A block is needed to evaluate for run_when") unless block_given?
      @run_condition = blk
    end

    def run(&blk)
      raise("A block is needed to run") unless block_given?
      @run_logic = blk
    end

    def priority=(priority)
      @priority = Integer(priority)
    end

    def concurrency=(level)
      raise("Concurrency has to be one of :safe, :unsafe") unless [:safe, :unsafe].include?(level)

      @concurrent = level
    end

    def concurrent_safe?
      @concurrent == :safe
    end

    def condition(name, &blk)
      raise("Duplicate condition name %s" % name) if @conditions[name]
      raise("A block is required for condition %s" % name) unless block_given?

      @conditions[name] = blk

      nil
    end

    def requirement(*args)
      case args.size
      when 1
        @needs << [nil, args[0]]
      when 2
        @needs << args
      else
        raise("Unsupported requirement input %s" % args.inspect)
      end
    end

    nil
  end
end
