class Noteikumi
  class State
    attr_reader :items, :results, :processed_by, :engine, :logger
    attr_writer :mutable

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
      rule.concurrent_safe? ? allow_mutation : prevent_mutation

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
    # @param requirements [Array<key,type>]
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
    # See {set} for a version of this that does not error if the
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
