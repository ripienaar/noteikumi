What?
=====

A Rule Engine for the Ruby Language.

I do operations work so this rule engine has some specific odd things
you might notice if you've used others before.

  * It's ordered, typically rule engines just run and rerun rules till
    nothing is interested anymore and does so in semi random order.
    For operations work this is awkwrd as you wouldn't want to reinstall
    servers over and over.  So for now rules have a priority and they
    are run in priority order.
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


Status?
-------

This is usable now, docs are in progress

Who?
----

R.I.Pienaar / rip@devco.net / @ripienaar / http://devco.net
