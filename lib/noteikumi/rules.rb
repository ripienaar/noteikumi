class Noteikumi
  # A collection of rules with various methods to load and find rules
  class Rules
    # The loaded rules
    # @return [Array<Rule>]
    attr_reader :rules

    # The logger
    # @api private
    # @return [Logger]
    attr_reader :logger

    # Creates a rule collection
    #
    # @param rules_dir [Array<String>,String] a directory or list of directories to look for rules in
    # @param logger [Logger] a logger to use
    # @return Rules
    def initialize(rules_dir, logger)
      @rules = []
      @logger = logger
      @rules_dir = Array(rules_dir)
    end

    # Use a block to select rules out of the overall set
    #
    # @param blk [Proc] logic to use when selecting rules
    # @return [Array<Rule>]
    def select(&blk)
      @rules.select(&blk)
    end

    # Return the rule ordered by priority
    #
    # @return [Array<Rule>]
    def by_priority
      @rules.sort_by(&:priority)
    end

    # The amont of rules loaded
    #
    # @return [Fixnum]
    def size
      @rules.size
    end
    alias_method :count, :size

    # Determines if any rules are loaded
    #
    # @return [Boolean]
    def empty?
      @rules.empty?
    end

    # Append a rule to the collection
    #
    # @param rule [Rule]
    # @return [Rule]
    def <<(rule)
      @rules << rule
    end

    # Get the names of all the rules
    #
    # @return [Array<String,Symbol>]
    def rule_names
      @rules.map(&:name)
    end

    # Load a rule from a file
    #
    # @param file [String] the file to load the rule from
    # @return [Rule]
    def load_rule(file)
      raise("The rule %s is not readable" % file) unless File.readable?(file)

      body = File.read(file)

      clean = Object.new
      rule = clean.instance_eval(body, file, 1)

      rule.file = file
      rule.logger = @logger

      logger.debug("Loaded rule %s from %s" % [rule.name, file])

      rule
    end

    # Load all the rules  from the configured paths
    #
    # @return [void]
    def load_rules
      @rules_dir.each do |directory|
        find_rules(directory).each do |rule|
          rule = load_rule(File.join(directory, rule))

          if rule_names.include?(rule.name)
            raise("Already have a rule called %s, cannot load another" % rule.name)
          end

          self << rule
        end
      end
    end

    # Find all rules in a given directory
    #
    # Valid rules have names ending in _\_rule.rb_
    #
    # @param directory [String] the directory to look in
    # @return [Array<String>] list of rule names
    def find_rules(directory)
      if File.directory?(directory)
        Dir.entries(directory).grep(/_rule.rb$/)
      else
        @logger.debug("Could not find directory %s while looking for rules" % directory)
        []
      end
    end
  end
end
