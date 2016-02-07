require "logger"

require "noteikumi/rule"
require "noteikumi/state"

class Noteikumi
  def self.rule(rule_name, options={}, &blk)
    options[:logger] ||= Logger.new(STDOUT)

    rule = Rule.new(rule_name, options)

    rule.instance_eval(&blk)

    rule
  end
end
