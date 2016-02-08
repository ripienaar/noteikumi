Noteikumi.rule(:needs_state) do
  requirement :answer, Fixnum

  rule_priority 999

  run do
    logger.info("The outcome is %d" % state[:answer])
  end
end


