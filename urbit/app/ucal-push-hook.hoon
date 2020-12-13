/-  ucal-store, *resource, *ucal-almanac, ucal-hook
/+  default-agent, push-hook, *resource, *ucal-almanac, ucal-util
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
++  on-watch
  |=  pax=path
  ^-  (quip card _this)
  :_  this
  ?+    pax  ~
      [@p %public-calendars ~]
    =/  who=@p  `@p`(slav %p `@tas`i.pax)
    ::  shouldn't get asked for another ship's public calendars
    ?>  =(who our.bowl)
    =/  cag=cage
        :-  %ucal-hook-update
        ^-  vase
        !>  ^-  update:ucal-hook
        :+  %metadata
          our.bowl
        =/  us=@tas  (scot %p our.bowl)
        =/  cals=(list calendar)
            .^  (list calendar)
              %gy
              us
              %ucal-store
              (scot %da now.bowl)
              us
              /calendars
            ==
        %+  turn
          ::  only expose calendars the querying ship can access
          %+  skim
            cals
          (bake (curr can-read-cal:ucal-util src.bowl) calendar)
        |=  cal=calendar
        ^-  metadata:ucal-hook
        [owner.cal title.cal calendar-code.cal]
    ::  now send a single update and terminate the subscription
    :~
      `card`[%give %fact ~ cag]
      `card`[%give %kick ~ ~]
    ==
  ==
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
  `resource.ts
::
++  take-update
  |=  =vase
  ^-  [(list card) agent]
  =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
  ::  if a calendar is removed, kick subs for the resource.
  ::  otherwise do nothing?
  ?.  ?=([%update *] +.ts)
    `this
  ?.  ?=([%calendar-removed *] update.ts)
    `this
  =/  =card  [%give %kick ~[(en-path resource.ts)] ~]
  :_  this
  ~[card]
::
++  initial-watch
  |=  [=path rid=resource]
  ^-  vase
  ::  TODO do we want any initial state in the path?
  ::  don't think so atm, but can be revisited
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
  =/  cal=calendar  (need (~(get-calendar al alma) cc))
  ::  subscribers must have read permissions. since they're
  ::  kicked on a permissions change, the will be stopped
  ::  from resubscribing here.
  ?>  (can-read-cal:ucal-util cal src.bowl)
  :^    rid
      %initial
    cal
  (need (~(get-events-bycal al alma) cc))
::
--
