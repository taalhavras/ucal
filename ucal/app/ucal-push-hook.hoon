/-  ucal-store, *resource, *ucal-almanac, ucal-hook
/+  default-agent, push-hook, *resource, *ucal-almanac, ucal-util, verb, dbug
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
      0  0
  ==
  ::
+$  agent  (push-hook:push-hook config)
--
%-  agent:dbug
%+  verb  |
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
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
        %noun
      ?>  =(our.bowl src.bowl)
      ?+    q.vase  (on-poke:def mark vase)
          %print-state
        ~&  %ucal-push-hook-has-no-state-to-print
        `this
      ==
  ==
++  on-agent  on-agent:def
++  on-watch
  |=  pax=path
  ^-  (quip card _this)
  :_  this
  ?+    pax  !!
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
              %gx
              (scot %p our.bowl)
              %ucal-store
              (scot %da now.bowl)
              /calendars/noun
            ==
        %+  turn
          ::  only expose calendars the querying ship can access
          %+  skim
            cals
          |=  cal=calendar
          ^-  flag
          (can-read-cal:ucal-util [owner permissions]:cal src.bowl)
        |=  cal=calendar
        ^-  metadata:ucal-hook
        [owner.cal title.cal calendar-code.cal]
    ::  now send a single update and terminate the subscription
    :~
      `card`[%give %fact ~ cag]
      `card`[%give %kick ~[/all] ~]
    ==
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
::
++  transform-proxy-update
  |=  vas=vase
  ^-  [(list card) (unit vase)]
  ::  TODO for now just always accept
  [*(list card) (some vas)]
::  NOTE: must be kept in sync with +resource-for-update in ucal-pull-hook
::
++  resource-for-update
  |=  =vase
  ^-  (list resource)
  =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
  ~[resource.ts]
::
++  take-update
  |=  =vase
  ^-  [(list card) agent]
  =/  ts=to-subscriber:ucal-store  !<(to-subscriber:ucal-store vase)
  ?.  ?=([%update *] +.ts)
    `this
  ::  watch path for the calendar we got an update for.
  ::  the hook library uses /resource/(en-path:resource resource)
  ::  as the subscription wires so we prepend /resource here.
  =/  pax=path  resource+(en-path resource.ts)
  ?:  ?=([%calendar-removed *] update.ts)
    ::  if a calendar is removed, kick all subs.
    =/  =card  [%give %kick ~[pax] ~]
    :_  this
    ~[card]
  ?:  ?=([%permissions-changed *] update.ts)
    ::  If this change revokes permissions we must kick
    ::  all current subscribers for the calendar who've
    ::  lost permissions. We can't just kick everyone who
    ::  is removed since they might not be subscribed in
    ::  the first place.
    ~&  [%sup sup.bowl]
    ~&  [%pax pax]
    ::  get all ships subscribed to this calendar
    =/  subscribed=(list ship)
        %+  turn
          %+  skim
            ~(tap by sup.bowl)
          |=  [=duct who=ship sub=path]
          ^-  flag
          =(sub pax)
        |=  [=duct who=ship sub=path]
        ^-  ship
        who
    ::  now filter subscribers into those who have lost read access
    =/  lost-access=(list ship)
        %+  skip
          subscribed
        %+  bake
          %+  cury
            can-read-cal:ucal-util
          [our.bowl calendar-permissions.update.ts]
        ship
    :_  this
    %+  turn
      lost-access
    |=  who=@p
    ^-  card
    [%give %kick ~[pax] `who]
  `this
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
        %gx
        (scot %p our.bowl)
        %ucal-store
        (scot %da now.bowl)
        /almanac/noun
      ==
  =/  cc=calendar-code  name.rid
  =/  cal=calendar  (need (~(get-calendar al alma) cc))
  ::  subscribers must have read permissions. since they're
  ::  kicked on a permissions change, they will be stopped
  ::  from resubscribing here.
  ?>  (can-read-cal:ucal-util [owner permissions]:cal src.bowl)
  :^    rid
      %initial
    cal
  (need (~(get-events-bycal al alma) cc))
::
--
