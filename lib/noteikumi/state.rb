class Noteikumi
  # The state a rule will process, this is not a state machine
  # but rather can be thought of like a scope
  class State
    # The list of result obtained from each rule
    # @return [Array<Result>]
    attr_reader :results

    # A list of rules that acted on this state
    # @return [Array<Rule>]
    attr_reader :processed_by

    # The engine this state is associated with
    # @api private
    # @return [Engine]
    attr_reader :engine

    # The logger used
    # @api private
    # @return [Logger]
    attr_reader :logger

    # Set the state mutable or not
    # @return [Boolean]
    attr_writer :mutable

    # Creates a new state
    #
    # @param engine [Engine]
    # @param logger [Logger]
    # @return [State]
    def initialize(engine, logger)
      @items = {}
      @results = []
      @processed_by = []
      @engine = engine
      @logger = logger
      @mutable = true
    end

    # Allow the state to be modified
    #
    # @return [void]
    def allow_mutation
      @mutable = true
    end

    # Prevent the state from being modified
    #
    # @return [void]
    def prevent_mutation
      @mutable = false
    end

    # Process a rule with the state
    #
    # @return [Result, nil] nil when the rule did not run
    def process_rule(rule)
      rule.concurrent_safe? ? prevent_mutation : allow_mutation

      result = rule.process(self)

      allow_mutation

      record_rule(rule, result)
    end

    # Yields each recorded result
    #
    # @yieldparam result [Result] for every rule that ran
    # @return [void]
    def each_result
      @results.each do |result|
        yield(result)
      end
    end

    # Adds a result to the list of results
    #
    # @param result [Result]
    # @return [Result]
    def add_result(result)
      @results << result if result
    end

    # Checks all results for failures
    #
    # @return [Boolean] true when there were failures
    def had_failures?
      @results.map(&:error?).include?(true)
    end

    # Determines if a rule with a specific name acted on this state
    #
    # @param rule [Rule,Symbol] the rule name or a rule
    # @return [Boolean]
    def processed_by?(rule)
      if rule.is_a?(Rule)
        @processed_by.include?(rule)
      else
        @processed_by.map(&:name).include?(rule)
      end
    end

    # Selects any item that has a certain ruby class type
    #
    # @param type [Class] the type to search for
    # @return [Hash] items found
    def items_by_type(type)
      @items.select {|_, v| v.is_a?(type)} || []
    end

    # Checks if a given requirement is matched by this state
    #
    # @example
    #
    #   state[:one] = "hello world"
    #
    #   state.meets_requirements?(:one, String) => [true, "reason"]
    #   state.meets_requirements?(nil, String) => [true, "reason"]
    #   state.meets_requirements?(nil, Fixnum) => [false, "State has no items of class Fixnum"]
    #   state.meets_requirements?(:one, Fixnum) => [false, "State item :one is not a Fixnum"]
    #   state.meets_requirements?(:not_set, Fixnum) => [false, "State has no item not_set"]
    #
    # @param requirement [Array<key,type>]
    # @return [Array<Boolean,String>]
    def meets_requirement?(requirement)
      key, klass = requirement

      if key
        return([false, "State has no item %s" % key]) unless include?(key)

        unless self[key].is_a?(klass)
          return [false, "State item %s is not a %s" % [key, klass]]
        end
      end

      unless has_item_of_type?(klass)
        return [false, "State has no items of class %s" % klass]
      end

      [true, "Valid state found"]
    end

    # Determines if any item in the State has a certain type
    #
    # @param type [Class] a ruby class to look for
    # @return [Boolean]
    def has_item_of_type?(type)
      !items_by_type(type).empty?
    end

    # Determines if the state can be mutated
    def mutable?
      !!@mutable
    end

    # Records a rule having acted on this state
    #
    # If the result is not nil the actor will be record
    # and the result stored, else it's a noop
    #
    # @param rule [Rule]
    # @param result [Result]
    # @return [void]
    def record_rule(rule, result)
      if result
        @processed_by << rule
        @results << result
      end

      result
    end

    # Checks if a item is in the state
    #
    # @param item [Symbol] item name
    # @return [Boolean]
    def include?(item)
      @items.include?(item)
    end
    alias_method :has?, :include?

    # sets the value of an item without checking if it's already set
    #
    # @param item [Symbol] the name of the item being stored
    # @param value [Object] the item to store
    # @return [Object] the item being stored
    # @raise [StandardError] when the state is not mutable
    def set(item, value)
      raise("State is not mustable") unless mutable?

      @items[item] = value
    end
    alias_method :[]=, :set

    # Deletes an item
    #
    # @param item [Symbol] item to delete
    # @raise [StandardError] when the state is not mutable
    def delete(item)
      raise("State is not mustable") unless mutable?

      @items.delete(item)
    end

    # Adds an item
    #
    # See {#set} for a version of this that does not error if the
    # item is already on the state
    #
    # @param item [Symbol] item to delete
    # @param value [Object] item to store
    # @return [Object] the value set
    # @raise [StandardError] when the state is not mutable
    # @raise [StandardError] when the item is already in the state
    def add(item, value)
      raise("State is not mustable") unless mutable?
      raise("Already have item %s" % item) if has?(item)

      set(item, value)
    end

    # Retrieves a item from the state
    #
    # @param item [Symbol] the item name
    # @return [Object,nil] the value stored
    def get(item)
      @items[item]
    end
    alias_method :[], :get
  end
end
