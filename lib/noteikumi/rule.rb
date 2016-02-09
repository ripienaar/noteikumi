class Noteikumi
  # A class that represents an individual rule used by the engine
  #
  # Rules are generally stored in files named something_rule.rb in a rule
  # directory, there are several samples of these in the examples dir
  # and in docs on the wiki at GitHub
  class Rule
    # The priority for this fule
    # @return [Fixnum]
    attr_reader :priority

    # The state this rule is being evaluated against
    # @api private
    # @return [State,nil]
    attr_reader :state

    # Named conditions for this rule
    # @api private
    # @see {condition}
    # @return [Hash]
    attr_reader :conditions

    # Items the rule expect on the state
    # @api private
    # @see {requirement}
    # @return [Array]
    attr_reader :needs

    # The concurrency safe level
    # @api private
    # @see {concurrency=}
    # @return [:safe, :unsafe]
    attr_reader :concurrent

    # The run conditions for this rule
    # @api private
    # @see {run_when}
    # @return [Proc]
    attr_reader :run_condition

    # The logic to run
    # @api private
    # @see {run}
    # @return [Proc]
    attr_reader :run_logic

    # How many times this rule have been run
    # @api private
    # @return [Fixnum]
    attr_reader :run_count

    # The file the rule was found in
    # @api private
    # @return [String]
    attr_accessor :file

    # The rule name
    # @api private
    # @return [String,Symbol]
    attr_accessor :name

    # The logger used by this rule
    # @api private
    # @return [Logger]
    attr_accessor :logger

    # Creates a new rule
    #
    # @param name [String,Symbol] the name of the rule
    # @return [Rule]
    def initialize(name)
      @name = name
      @priority = 500
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

    # Resets the run count for the rule to 0
    #
    # @return [void]
    def reset_counter
      @run_count = 0
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

    # :nodoc:
    # @return [String]
    def to_s
      "#<%s:%s run_count: %d priority: %d name: %s @ %s>" % [self.class, object_id, run_count, priority, name, file]
    end

    # Logic to execute once state has met to determine if the rule should be run
    #
    # @see #condition for an example
    # @param blk [Proc] the checking logic that should return boolean
    # @return [void]
    def run_when(&blk)
      raise("A block is needed to evaluate for run_when") unless block_given?
      @run_condition = blk
    end

    # Creates the logic that will be run when all the conditions are met
    #
    # @see #requirement
    # @see #condition
    # @see #run_when
    # @param blk [Proc] the logic to run
    # @return [void]
    def run(&blk)
      raise("A block is needed to run") unless block_given?
      @run_logic = blk
    end

    # Sets the rule priority
    #
    # @param priority [Fixnum]
    # @return [Fixnum]
    def rule_priority(priority)
      @priority = Integer(priority)
    end

    # Sets the concurrency safe level
    #
    # This is mainly not used now but will result in the state becoming immutable
    # when the level is :safe.  This is with an eye on supporting parallel or threaded
    # execution of rules in the long term
    #
    # @param level [:safe, :unsafe]
    # @return [:safe, :unsafe]
    def concurrency=(level)
      raise("Concurrency has to be one of :safe, :unsafe") unless [:safe, :unsafe].include?(level)

      @concurrent = level
    end

    # Determines if the concurrency level is :safe
    #
    # @return [Boolean]
    def concurrent_safe?
      @concurrent == :safe
    end

    # Creates a named condition
    #
    # @example create and use a condition
    #
    #  condition(:weekend?) { Time.now.wday > 5 }
    #  condition(:daytime?) { Time.now.hour.between?(9, 18) }
    #
    #  run_when { weekend? || !daytime? }
    #
    # @note these blocks must always return boolean and will be coerced to that
    # @param name [Symbol] a unique name for this condition
    # @param blk [Proc] the code to run when this condition is called
    # @return [void]
    def condition(name, &blk)
      raise("Duplicate condition name %s" % name) if @conditions[name]
      raise("A block is required for condition %s" % name) unless block_given?

      @conditions[name] = blk

      nil
    end

    # Sets a requirement that the state should meet
    #
    # @example require any scope item with a specific type
    #
    #    requirement nil, String
    #
    # @example require that a specific item should be of a type
    #
    #    requirement :thing, String
    #
    # @param args [Array] of requirements
    # @return [void]
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
