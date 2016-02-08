Noteikumi.rule(:first_rule) do
  rule_priority(10)

  run do
    raise("simulated error")
  end
end
