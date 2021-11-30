/-  ucal, ucal-sync
/+  default-agent
|%
+$  card  card:agent:gall
::  $per-cal-state: state we track per calendar.
::
::    url: The url we are fetching
::    timeout: The frequency to poll the url
::    next-request-time: The time the next request will fire
::
+$  per-cal-state  [url=tape timeout=@dr next-request-time=@da]
::
+$  state-zero
  $:  cals=(map calendar-code:ucal per-cal-state)
  ==
::
+$  versioned-state
  $%  [%0 state-zero]
  ==
--
::
=|  state=versioned-state
::
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    helper  ~(. +> bowl)
    def   ~(. (default-agent this %|) bowl)
++  on-init  on-init:def
::
++  on-save
  ^-  vase
  !>(state)
::
++  on-load
  |=  =vase
  ^-  (quip card _this)
  :-  ~
  =/  prev  !<(versioned-state vase)
  ?-  -.prev
    %0  this(state prev)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ::  Can only be poked by us or our moons
  ?>  (team:title our.bowl src.bowl)
  ?+    mark  `this
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  state
      `this
    ::
        %reset-state
      `this(state *versioned-state)
    ==
  ::
      %ucal-sync-action
    =/  action  !<(action:ucal-sync vase)
    ?-    -.action
        %add
      ::  Cannot add an already existing calendar
      ?>  !(~(has by cals.state) cc.action)
      ::  send a request for the calendar immediately.
      =/  pcs=per-cal-state  [url.action timeout.action (add now.bowl timeout.action)
      :-  state(cals (~(put by cals.state) cc.action pcs))
      ~[(request-url url.action cc.action)]
    ::
        %remove
      ::  delete entry from map and clear any future timers.
      !!
    ::
        %force
      !!
    ::
        %adjust
      !!
    ==
  ==
::
++  on-watch  on-watch:def
::
++  on-leave  on-leave:def
::
++  on-peek  on-peek:def
::
++  on-agent  on-agent:def
::
++  on-arvo
  |=  [wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%ucal-sync %update cc=@ta ~]
    ::  Time to re-issue a GET request for a given url
    =/  pcs=per-cal-state  (~(got by cals.state) cc)
    [state ~[(request-url url.pcs cc)]]
      [%ucal-sync %request cc=@ta ~]
    ::  Process response to our GET request
    =/  pcs=per-cal-state  (~(got by cals.state) cc)
    =/  nrt=@da  (add now timeout.pcs)
    =/  new=per-cal-state  pcs(next-request-time nrt)
    =/  ucal-card=(unit card)  (poke-ucal sign-arvo cc)
    =/  update-card=card  (schedule-future-update cc nrt)
    =/  loc=(list card)  ?~(ucal-card ~[update-card] ~[update-card u.ucal-card])
    :-  loc
    state(cals (~(put by cals.state) cc new))
  ==
::
++  on-fail  on-fail:def
--
::  Helper door
::
|_  =bowl:gall
++  schedule-future-update
  |=  [cc=calendar-code scheduled-for=@da]
  ^-  card
  [%pass /ucal-sync/update/[cc] %arvo %b [%wait scheduled-for]]
::
++  cancel-future-update
  |=  cc=calendar-code
  ^-  card
  =/  nrt=@da  next-request-time:(~(got by cals.state) cc)
  [%pass /ucal-sync/update/[cc] %arvo %b [%rest nrt]]
::
++  request-url
  |=  [url=tape cc=calendar-code]
  ^-  card
  =/  =request:http  [%'GET' (crip url) ~ ~]
  =/  =task:iris  [%request request *outbound-config:iris]
  [%pass /ucal-sync/request/[cc] %arvo %i task]
::  +poke-ucal: given a sign that's a resposne to an iris GET request
::  returns a card to poke ucal with. returns ~ if the response to the
::  GET request is malformed in some way.
::
++  poke-ucal
  |=  [=sign-arvo cc=calendar=code]
  ^-  (unit card)
  !!
--
