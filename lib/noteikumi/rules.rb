class Noteikumi
  class Rules
    attr_reader :rules, :logger

    def initialize(rules_dir, logger)
      @rules = []
      @logger = logger
      @rules_dir = Array(rules_dir)
    end

    def select(&blk)
      @rules.select(&blk)
    end

    def by_priority
      @rules.sort_by(&:priority)
    end

    def [](rule)
      @rules[rule]
    end

    def size
      @rules.size
    end
    alias_method :count, :size

    def empty?
      @rules.empty?
    end

    def <<(rule)
      @rules << rule
    end

    def load_rule(file)
      raise("The rule %s is not readable" % file) unless File.readable?(file)

      body = File.read(file)

      clean = Object.new
      rule = clean.instance_eval(body, file, 1)
      rule.file = file
      rule.logger = @logger

      self << rule

      logger.debug("Loaded rule %s from %s" % [rule.name, file])

      rule
    end

    def load_rules
      @rules_dir.each do |directory|
        find_rules(directory).each do |rule|
          load_rule(File.join(directory, rule))
        end
      end
    end

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
