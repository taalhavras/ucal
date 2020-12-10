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
  ?+    mark  `this
      %ucal-pull-hook-action
    =/  act=action:ucal-hook  !<(action:ucal-hook vase)
    :-  this
    !!
  ==
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
  `/
--
