class Noteikumi
  # The main driver of the rule set
  #
  # @example create a engine and process some data
  #
  #   engine = Engine.new("rules")
  #   state = engine.create_state
  #
  #   state[:thing] = data_to_process
  #
  #   engine.process_state(state)
  #
  #   puts "%d rules ran" % [state.results.size]
  class Engine
    # The paths this engine consulted for rules
    #
    # @return [Array<String>] list of paths
    attr_reader :path

    # Creates an instance of the rule engine
    #
    # @param path [String] a File::PATH_SEPARATOR list of paths to load rules from
    # @param logger [Logger]
    # @return [Engine]
    def initialize(path, logger=Logger.new(STDOUT))
      @logger = logger
      @path = parse_path(path)

      rules_collection.load_rules
    end

    # Parse a File::PATH_SEPARATOR seperated path into expanded directories
    #
    # @api private
    # @param path [String] The path to parse, should be a File::PATH_SEPARATOR list of paths
    # @return [Array<String>]
    def parse_path(path)
      path.split(File::PATH_SEPARATOR).map do |part|
        File.expand_path(part)
      end
    end

    # Reset the run count on all loaded rules
    #
    # @api private
    # @return [void]
    def reset_rule_counts
      rules_collection.rules.each(&:reset_counter)
    end

    # Given a state object process all the loaded rules
    #
    # @note the rule set is processed once only
    # @param state [State]
    # @return [Array<Result>]
    def process_state(state)
      raise("No rules have been loaded into engine %s" % self) if rules_collection.empty?

      reset_rule_counts

      rules_collection.by_priority.each do |rule|
        state.process_rule(rule)
      end

      state.results
    end

    # Creates a new state that has an associated with this {Engine}
    #
    # @return [State]
    def create_state
      State.new(self, @logger)
    end

    # Iterates all the rules in the {Rules} collection
    #
    # @yieldparam rule [Rule]
    # @return [void]
    def each_rule
      rules_collection.rules.each do |rule|
        yield(rule)
      end
    end

    # Creates and caches a rules collection
    #
    # @return [Rules]
    def rules_collection
      @rules ||= Rules.new(@path, @logger)
    end

    # :nodoc:
    # @return [String]
    def inspect
      "#<%s:%s %d rules from %s>" % [self.class, object_id, rules_collection.count, @path.inspect]
    end
  end
end
