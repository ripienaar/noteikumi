require "logger"

require "noteikumi/engine"
require "noteikumi/result"
require "noteikumi/rule"
require "noteikumi/rule_condition_validator"
require "noteikumi/rule_execution_scope"
require "noteikumi/rules"
require "noteikumi/state"

# A light weight rule engine
#
# Visit https://github.com/ripienaar/noteikumi for more information
class Noteikumi
  # Helper to create a new rule from a block
  #
  # @param rule_name [String,Symbol] unique name for this rule, Symbols preferred
  # @param blk [Proc] the rule body with access to methods on {Rule}
  # @return [Rule]
  def self.rule(rule_name, &blk)
    rule = Rule.new(rule_name)

    rule.instance_eval(&blk)

    rule
  end

  # Helper to create a new {Engine}
  #
  # @param path [String] a File::PATH_SEPARATOR seperated list of paths to load rules from
  # @param logger [Logger] a logger to use
  # @return [Engine]
  def self.new_engine(path, logger)
    Engine.new(path, logger)
  end
end
