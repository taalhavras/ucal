/-  ucal-store, *resource, *ucal-almanac
/+  default-agent, push-hook, resource
=>
|%
+$  card  card:agent:gall
::
++  config
  ^-  config:push-hook
  :*  %ucal-store
      /almanac :: sub path for all store updates
      to-subscriber:ucal-store
      %ucal-to-subscriber
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
  ::  TODO for now just always accept
  &
::
++  resource-for-update
  |=  =vase
  ^-  (unit resource)
  ~&  %resource-for-update
  =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
  `resource.ts
::
++  take-update
  |=  =vase
  ^-  [(list card) agent]
  =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
  ~&  [%take-update ts]
  ::  if a calendar is removed, kick subs for the resource.
  ::  otherwise do nothing?
  ?.  ?=([%update *] +.ts)
    `this
  ?.  ?=([%calendar-removed *] update.ts)
    `this
  =/  =card  [%give %kick ~[(en-path:resource resource.ts)] ~]
  :_  this
  ~[card]
::
++  initial-watch
  |=  [=path rid=resource]
  ^-  vase
  ~&  [%ucal-push-hook-initial-watch path rid]
  ::  TODO do we want any initial state in the path?
  ::  don't think so atm, but can be revisited
  ::  TODO ok so what about the resource? since we're
  ::  just dumping the whole almanac it also doesn't
  ::  matter...
  !>  ^-  to-subscriber:ucal-store
  ::  get the whole almanac, then do our lookups on it
  =/  us=@tas  (scot %p our.bowl)
  =/  alma=almanac
      .^  almanac
        %gy
        us
        %ucal-store
        (scot %da now.bowl)
        us
        /almanac
      ==
  =/  cc=calendar-code  name.rid
  :^  rid  %initial
    (~(got by cals.alma) cc)
  (~(get ja events.alma) cc)
::
--
