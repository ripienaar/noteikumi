Noteikumi.rule(:rspec) do
  requirement :string, String
  requirement Integer

  condition(:one) { true }
  condition(:two) { false }

  run_when do
    one && !two
  end

  run do
    raise(state[:raise_this]) if state[:raise_this]
    sleep(state[:sleep_time]) if state[:sleep_time]

    state[:string]
  end
end
