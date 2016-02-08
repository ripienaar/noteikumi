#!/usr/bin/env ruby

# By default rules run even when earlier rules fail, this might
# not always be desired so there is a built-in condition called
# state_had_failures? that returns true if there was any errors

$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require "noteikumi"
require File.join(File.dirname(__FILE__), "demo_util.rb")

engine = Noteikumi.new_engine("rules/skip_on_error", Logger.new(STDOUT))
state = engine.create_state
engine.process_state(state)

puts
if state.results.size == 1
  puts "Only one rule ran as expected"
else
  puts "More than one rule ran, something is not right"
end
puts

report(state)
