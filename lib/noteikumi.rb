require "logger"

require "noteikumi/engine"
require "noteikumi/result"
require "noteikumi/rule"
require "noteikumi/rule_condition_validator"
require "noteikumi/rule_execution_scope"
require "noteikumi/rules"
require "noteikumi/state"

class Noteikumi
  def self.rule(rule_name, &blk)
    rule = Rule.new(rule_name)

    rule.instance_eval(&blk)

    rule
  end

  def self.new_engine(path, logger)
    Engine.new(path, logger)
  end
end
