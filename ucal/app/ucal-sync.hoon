/-  ucal, ucal-sync, ucal-store
/+  default-agent
|%
+$  card  card:agent:gall
+$  calendar-code  calendar-code:ucal
::  $per-cal-state: state we track per calendar.
::
::    url: The url we are fetching
::    timeout: The frequency to poll the url
::    next-request-time: The time the next request will fire
::
+$  per-cal-state  [url=tape timeout=@dr next-request-time=@da]
::
+$  state-zero
  $:  cals=(map calendar-code per-cal-state)
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
    =^  cards  state  (handle-ucal-sync-poke:helper action)
    [cards this]
  ==
::
++  on-watch  on-watch:def
::
++  on-leave  on-leave:def
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path
    (on-peek:def path)
  ::
      [%x %sync-active @tas ~]
    =/  cc=calendar-code  i.t.t.path
    ``ucal-sync-present+!>((~(has by cals.state) cc))
  ==
::
++  on-agent  on-agent:def
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%ucal-sync %update @ta ~]
    ::  Time to re-issue a GET request for a given url
    =/  pcs=per-cal-state  (~(got by cals.state) i.t.t.wire)
    :_  this
    `(list card)`~[(request-url url.pcs i.t.t.wire)]
  ::
      [%ucal-sync %request @ta ~]
    ::  Process response to our GET request
    =/  pcs=per-cal-state  (~(got by cals.state) i.t.t.wire)
    =/  nrt=@da  (add now.bowl timeout.pcs)
    =/  new=per-cal-state  pcs(next-request-time nrt)
    =/  ucal-card=(unit card)  (poke-ucal sign-arvo i.t.t.wire url.pcs)
    =/  update-card=card  (schedule-future-update i.t.t.wire nrt)
    =/  loc=(list card)  ?~(ucal-card ~[update-card] ~[update-card u.ucal-card])
    =.  state  state(cals (~(put by cals.state) i.t.t.wire new))
    [loc this]
  ==
::
++  on-fail  on-fail:def
--
::  Helper door
::
|_  =bowl:gall
++  handle-ucal-sync-poke
  |=  =action:ucal-sync
  ^-  (quip card _state)
  ?-    -.action
      %add
    ::  Cannot add an already existing calendar
    ?>  !(~(has by cals.state) cc.action)
    ::  send a request for the calendar immediately.
    =/  pcs=per-cal-state  [url.action timeout.action (add now.bowl timeout.action)]
    :_  state(cals (~(put by cals.state) cc.action pcs))
    ~[(request-url url.action cc.action)]
  ::
      %remove
    ::  delete entry from map and clear any future timers.
    ::  note that we may still get a response from an in-flight
    ::  request to %iris but we'll properly handle that by crashing in
    ::  ++on-arvo below.
    :_  state(cals (~(del by cals.state) cc.action))
    =/  cancel-time=@da  next-request-time:(~(got by cals.state) cc.action)
    ~[(cancel-future-update cc.action cancel-time)]
  ::
      %adjust
    =/  old=per-cal-state  (~(got by cals.state) cc.action)
    ?:  =(new-timeout.action timeout.old)
      `state
    ::  It's possible that this ends up being the same as the existing
    ::  next request time. However since %rest only removes a single
    ::  timer from behn this is fine - it'll still fire only once.
    =/  nrt=@da  (add new-timeout.action now.bowl)
    =/  new=per-cal-state
    %=  old
      timeout  new-timeout.action
      next-request-time  nrt
    ==
    :_  state(cals (~(put by cals.state) cc.action new))
    :~  (cancel-future-update cc.action next-request-time.old)
        (schedule-future-update cc.action nrt)
    ==
  ==
::  +schedule-future-update: set a %behn timer for the specified @da
::
++  schedule-future-update
  |=  [cc=calendar-code scheduled-for=@da]
  ^-  card
  [%pass /ucal-sync/update/[cc] %arvo %b [%wait scheduled-for]]
::  +cancel-future-update: cancel a %behn timer for the specified @da
::
++  cancel-future-update
  |=  [cc=calendar-code scheduled-for=@da]
  ^-  card
  [%pass /ucal-sync/update/[cc] %arvo %b [%rest scheduled-for]]
::  +request-url: send a GET request to a specified url.
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
  |=  [sign=sign-arvo cc=calendar-code url=tape]
  ^-  (unit card)
  ?.  ?=([%iris %http-response %finished *] sign)
    ::  No need to complain about anything here - we could
    ::  be receiving %progess for instance.
    ~
  ?~  full-file.client-response.sign
    ::  Here we do want to complain - this indicates that
    ::  the data we got back couldn't be parsed to MIME
    %-
      %-  slog
      :~  leaf+"ucal-sync: failed to import data from {url}"
          leaf+"if this persists consider running the following command"
          leaf+"to stop requests for this calendar."
          leaf+":ucal-sync &ucal-sync-action [%remove {(trip cc)}"
      ==
    ~
  =/  data=@t  `@t`q.data.u.full-file.client-response.sign
  =/  =task:agent:gall
  [%poke %ucal-action !>(`action:ucal-store`[%import-from-ics (some cc) %data data])]
  %-  some
  [%pass /ucal-sync/poke-ucal/[cc] %agent [our.bowl %ucal-store] task]
--
