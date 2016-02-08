def report(state)
  engine = state.engine
  rules = engine.rules_collection

  puts "State Report"
  puts "============"
  puts
  puts "%d rules loaded from %s" % [rules.size, engine.path.join(":")]
  puts "%d rules processed the state" % state.results.size
  puts "Rules had failures: %s" % state.had_failures?

  puts

  state.results.each do |result|
    puts result.rule
    puts "       Error: %s" % result.error?
    puts "      Output: %s" % result.output

    if result.error?
      exception = result.exception

      puts "   Exception: %s: %s: %s" % [exception.class, exception.backtrace[0], exception.to_s]
    end

    puts
  end
end
