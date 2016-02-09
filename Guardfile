group :noteikumi, :halt_on_fail => true do
  guard :shell do
    rspec_command = "rspec --color --format=doc --fail-fast %s"
    syntax_check_command = "ruby -c %s"

    watch(%r{^spec/unit/(.+)\.rb$}) do |m|
      if File.exist?(m.first)
        puts("%s: %s" % ["*" * 20, m.first])
        system(rspec_command % m) || throw(:task_has_failed)
      end
    end

    watch(%r{^lib/(.+)\.rb$}) do |m|
      spec = "spec/unit/%s_spec.rb" % m[1]

      puts("%s: %s" % ["*" * 20, m.first])
      if File.exist?(spec)
        system(rspec_command % spec) || throw(:task_has_failed)
      else
        print("No tests found, checking syntax: ")
        system(syntax_check_command % m.first) || throw(:task_has_failed)
      end
    end
  end

  guard :shell do
    rubocop_command = %w{rubocop -f progress -f offenses}

    watch(%r{^lib|spec|examples/(.+)\.rb$}) do |m|
      rubocop_command << "--fail-fast" << m.first
      system(rubocop_command.join(" ")) || throw(:task_has_failed)
    end

    watch(".rubocop.yml") do
      rubocop_command << "lib" << "spec" << "examples"
      system(rubocop_command.join(" ")) || throw(:task_has_failed)
    end
  end
end
