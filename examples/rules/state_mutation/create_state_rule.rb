Noteikumi.rule(:creates_state) do
  requirement :v_1, Fixnum
  requirement :v_2, Fixnum

  rule_priority 500

  run do
    state[:answer] = state[:v_1] + state[:v_1]
  end
end
