:: pull hook
/-  *pull-hook, *resource, ucal-store
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
--
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
++  on-poke  on-poke:def
++  on-agent  on-agent:def
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
