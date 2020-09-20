/-  ucal-store
/+  default-agent, push-hook
=>
|%
+$  card  card:agent:gall
::
++  config
  ^-  config:push-hook
  :*  %ucal-store
      / :: TODO what's this path?
      update:ucal-store
      %ucal-update
      %ucal-pull-hook
  ==
  ::
+$  agent  (push-hook:push-hook config)
--
^-  agent:gall
%-  (agent:push-hook config)
^-  agent
|_  =bowl:gall
+*  this        .
    def         ~(. (default-agent this %|) bowl)
    grp       ~(. grpl bowl)
::
++  on-init  on-init:def
++  on-save  !>(~)
++  on-load    on-load:def
++  on-poke   on-poke:def
++  on-agent  on-agent:def
++  on-watch    on-watch:def
++  on-leave    on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
::
++  should-proxy-update
  |=  =vase
  ^-  flag
  =/  =update:ucal-store  !<(update:ucal-store vase)
  &
::
++  resource-for-update
  |=  =vase
  ^-  (unit resource)
  !!
::
++  take-update
  |=  =vase
  ^-  [(list card) agent]
  !!
::
++  initial-watch
  |=  [=path rid=resource]
  ^-  vase
  ::  TODO so is path here the suffix? I guess so...
  !!
::
--
