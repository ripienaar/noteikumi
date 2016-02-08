class Noteikumi
  class Engine
    def initialize(path, logger=Logger.new(STDOUT))
      @logger = logger
      @path = path.split(File::PATH_SEPARATOR)

      rules_collection.load_rules
    end

    def process_state(state)
      raise("No rules have been loaded into engine %s" % self) if rules_collection.empty?

      rules_collection.by_priority.each do |rule|
        state.process_rule(rule)
      end

      state.results
    end

    def create_state
      State.new(self, @logger)
    end

    def each_rule
      rules_collection.rules.each do |rule|
        yield(rule)
      end
    end

    def rules_collection
      @rules ||= Rules.new(@path, @logger)
    end

    def inspect
      "#<%s:%s %d rules from %s>" % [self.class, object_id, rules_collection.count, @path.inspect]
    end
  end
end
