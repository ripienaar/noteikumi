What?
=====

A Rule Engine for the Ruby Language.

I do operations work so this rule engine has some specific odd things
you might notice if you've used others before.

  * It's ordered, typically rule engines just run and rerun rules till
    nothing is interested anymore and does so in semi random order.
    For operations work this is awkwrd as you wouldn't want to reinstall
    servers over and over or do things in semi random order.  So for now
    rules have a priority and they are run in priority order.
  * Rules are run once only, as above rule engines tend to run rules
    many times over and I think it's weird for operations. So right now
    rules are run once only.  This is something I want to change, already
    rules track their run count and there are state checks to help creating
    certain rules that are once only.
  * It's kind of optimised for not massive sets of rules, as such it does
    not use the RETE algorithm to optimise the rule selection.  This is
    because typically state processing rule engines are set up and then
    ran 1000s of times over - once per event.  The RETE algorithm makes doing
    that very efficient.  For the kind of things I need to do now I'll
    generally drive things like deploys of containers - not something that
    is specifically stream processing or require vast rule sets

Why a Rule Engine?
------------------

Rule engines lets you externalise your business logic. In a complex workflow
based system you end up hard coding your deployment flows in the program and
adjusting the flows can be very difficult.

Imagine you have a system that constantly deploy Docker containers based
on the status of a tool like etcd.  It migth have steps like this:

```ruby
if etcd_updated(container)
  fetch_container_image(container)
  stop_container(container)
  start_container(container)
  check_container(container)
  notify_operators(container)
end
```

This is hard coded and quite rigid.  If I wanted to support other notification
methods - email, slack, hipchat etc - I would need to create some kind of plugin
system where different notification methods can be implemented via this prescribed
plugin structure.

This is pretty annoying, even though your users can provide the notification logic
maintaining the plugin system APIs and worrying about versioning these APIs etc
can be quite a burden.

With a rule engine you extract this logic out to small bits of code that called rules
which are basically if / then blocks.

```ruby
# create an engine that loads rules from the 'rules' directory
engine = Noteikumi.new_engine("rules", Logger.new(STDOUT))
state = engine.create_state

# add the scope the rules have access to
state[:desired_state] = etcd_desired_state(container)
state[:container] = container

# run all matching rules
engine.process_state(state)
```

At this point there's no business logic in the actual code base and you can start
thinking of ways to build up the logic in small parts.  Lets assume the rule set
to deploy the container exists but now a user want to add some logic.  Examples
migth be:

  * Notify slack about containers being created
  * Write to an external discovery database post deploy
  * Prevent a deployment from running based on some criteria like Time of day
  * Drain traffic from the container before deploying it
  * Create a RBAC system that prevents certain users from deploying certain software
  * Call out to monitoring systems removing a container about to be deployed and adding the new one to it

The list is endless and it's inconceivable that every possible plugin you might
want can be supported by the developer of the deployer.

You'd create rules by priority, for example place the core deployer logic at priority
500 and so a rule before that priority could prevent further processing or ones after
that can do notifications.

Here's a rule to notify slack post deploy, note the `state.had_failures?`, all rules are
ran if they are interested in the state.  So this rule will run even when earlier ones
had failed or raised exceptions so you can handle both notification scenarios here:

```ruby
Noteikumi.rule(:post_deploy_slack) do
  # scope needs some keys, see earlier state[...] lines, this assert that
  # specific scope keys have very specific class types
  requirement :container, My::Container

  priority = 999

  run do
    container = state[:container]

    require "slack-notifier"
    notifier = Slack::Notifier.new(....)

    if state.had_failures?
      notifier.ping("Failed to deploy container %s at %s using tag %s" % [container.name, container.deploy_time, container.tag])
    else
      notifier.ping("Deployed container %s at %s using tag %s" % [container.name, container.deploy_time, container.tag])
    end
  end
end
```

And here's one that prevents deployments out of hours:

```ruby
Noteikumi.rule(:work_time_deploys) do
  requirement :container, My::Container

  priority = 10

  condition(:weekend?) { Time.now.wday > 5 }
  condition(:daytime?) { Time.now.hour.between?(9, 18) }

  run_when { weekend? || !daytime? }

  run do
    raise("Deployment of container %s out of work hours prevented" % state[:container].name)
  end
end
```

Generally this work hours check would be pretty strange especially for containers I guess,
having a rule based deployer means it can easily be implemented even if the developers
of the tool does not support it.  They just have to provide a convenient way to have
user supplied rules.

Status?
-------

This is usable now, docs are in progress.  See the `examples` directory.

Who?
----

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net
