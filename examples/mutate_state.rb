#!/usr/bin/env ruby

# You might need to mutate the state, like computing some value in
# earlier rules and referencing it in later ones.
#
# I use this to set flags that disable or enable certain sets of rules
#
# In the example in rules/state_mutation a simple calculation is done
# and the answer is displayed
#
# If a rule is set to be concurrent safe then the state is not mutable
# and no change can be made and no items added or removed from the state

$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require "noteikumi"
require File.join(File.dirname(__FILE__), "demo_util.rb")

engine = Noteikumi.new_engine("rules/state_mutation", Logger.new(STDOUT))
state = engine.create_state

state[:v_1] = 1
state[:v_2] = 2

engine.process_state(state)

puts
if state.has?(:answer)
  puts "Computed answer: %d" % state[:answer]
else
  puts "Failed to compute the answer"
end
puts

report(state)
