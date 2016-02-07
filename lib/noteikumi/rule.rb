class Noteikumi
  class Rule
    attr_reader :priority, :concurrent, :needs, :conditions, :state
    attr_reader :run_condition, :run_logic
    attr_accessor :file, :name, :state, :logger

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

      run_when { true }
      run { raise("No execution logic provided for rule") }
    end

    def to_s
      "#<%s:%s priority: %d name: %s @ %s>" % [self.class, object_id, priority, name, file]
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
        raise("Unsupported needs input %s" % args.inspect)
      end
    end

    nil
  end
end
