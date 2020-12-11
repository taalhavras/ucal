:: pull hook
/-  *pull-hook, *resource, ucal-store, ucal-hook, *ucal
/+  pull-hook, default-agent
=>
|%
+$  card  card:agent:gall
::
++  config
  ^-  config:pull-hook
  :*  %ucal-store
      to-subscriber:ucal-store
      %ucal-to-subscriber
      %ucal-push-hook
  ==
::
::
+$  state-zero
  $:
    entries=(jar entity metadata:ucal-hook)
  ==
::
+$  versioned-state
  $%
    [%0 state-zero]
  ==
--
::
::::  state
::
=|  state=versioned-state
::
^-  agent:gall
%-  (agent:pull-hook config)
^-  (pull-hook:pull-hook config)
|_  =bowl:gall
+*  this        .
    def         ~(. (default-agent this %|) bowl)
    dep         ~(. (default:pull-hook this config) bowl)
::
::
++  on-init  on-init:def
++  on-save  !>(~)
++  on-load  on-load:def
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ~&  [%ucal-pull-hook-on-poke mark vase]
  (on-poke:def mark vase)
++  on-agent
  |~  [=wire =sign:agent:gall]
  ~&  [%ucal-pull-hook-on-agent wire sign]
  (on-agent:def wire sign)
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
++  on-pull-nack
  |=   [=resource =tang]
  ^-  (quip card _this)
  [~ this]
++  on-pull-kick
  |=  =resource
  ^-  (unit path)
  ::  the metadata resource sends an initial update and then kicks
  ::  immediately, so we don't want to resubscribe
  ?:  =(resource [our.bowl public-calendars:ucal-hook])
    ~
  `/
--
