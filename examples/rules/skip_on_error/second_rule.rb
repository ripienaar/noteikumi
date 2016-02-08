Noteikumi.rule(:second_rule) do
  run_when { !state_had_failures? }

  run do
    "this should never return"
  end
end
