require "logger"

require "noteikumi/rule"
require "noteikumi/rules"
require "noteikumi/state"

class Noteikumi
  def self.rule(rule_name, &blk)
    rule = Rule.new(rule_name)

    rule.instance_eval(&blk)

    rule
  end
end
