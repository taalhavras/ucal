/-  ucal-store, *resource, *ucal-almanac
/+  default-agent, push-hook, resource
=>
|%
+$  card  card:agent:gall
::
++  config
  ^-  config:push-hook
  :*  %ucal-store
      /calendars :: sub path for all store updates
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
  ::  TODO for now just always accept
  &
::
++  resource-for-update
  |=  =vase
  ^-  (unit resource)
  =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
  ?:  ?=([%initial *] ts)
    ~
  `resource.update.ts
::
++  take-update
  |=  =vase
  ^-  [(list card) agent]
  =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
  ::  if a calendar is removed, kick subs for the resource.
  ::  otherwise do nothing?
  ?.  ?=([%update *] ts)
    `this
  ?.  ?=([%calendar-removed *] (tail update.ts))
    `this
  =/  =card  [%give %kick ~[(en-path:resource resource.update.ts)] ~]
  :_  this
  ~[card]
::
++  initial-watch
  |=  [=path rid=resource]
  ^-  vase
  ::  TODO do we want any initial state in the path?
  ::  don't think so atm, but can be revisited
  ::  TODO ok so what about the resource? since we're
  ::  just dumping the whole almanac it also doesn't
  ::  matter...
  !>  ^-  to-subscriber:ucal-store
  :-  %initial
  .^  almanac
    %gy
    (scot %p our.bowl)
    %ucal-store
    (scot %da now.bowl)
    /calendars
  ==
::
--
