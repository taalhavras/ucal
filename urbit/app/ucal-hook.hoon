/-  ucal, ucal-hook
/+  default-agent
::
::: local types
::
|%
:: aliases
+$  card   card:agent:gall
+$  cal    calendar:ucal
+$  calendars  calendars:ucal
+$  event  event:ucal
+$  calendar-code  calendar-code:ucal
+$  event-code  event-code:ucal
::
::  TODO figure out what this will actually contain - probably some
::  permissions stuff.
+$  state-zero
  $:
    a=@
  ==
::
+$  versioned-state
  $%
    [%0 state-zero]
  ==
--
::
::: state
::
=|  state=versioned-state
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .                                           :: the agent itself
      do    ~(. +> bowl)                                :: helper core
      def   ~(. (default-agent this %|) bowl)           :: default/"stub" arms
  ++  on-init  on-init:def
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load  ::on-load:def
    |=  =vase
    ^-  (quip card _this)
    :-  ~                                               :: no cards to emit
    =/  prev  !<(versioned-state vase)
    ?-  -.prev
      %0  this(state prev)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?+    mark  (on-poke:def mark vase)
        %noun
      ?>  (team:title our.bowl src.bowl)
      ::
      :: these are for debugging
      ::
      ?+    q.vase  (on-poke:def mark vase)
          %print-state
        ~&  state
        `this  :: irregular syntax for '[~ this]'
      ::
          %reset-state
        `this(state *versioned-state)  :: irregular syntax for bunt value
      ==
    ::
        %ucal-hook-action
      =^  cards  state  (poke-ucal-hook-action:do !<(action:ucal-hook vase))
      [cards this]
    ==
  ::
  ++  on-watch  on-watch:def
  ++  on-agent
    |=  [=wire sign=sign:agent:gall]
    ^-  (quip card _this)
    ~&  [%on-agent wire]
    ?+  wire  `this
        [%calendars @tas ~]
      =/  from=ship  (slav %p i.t.wire)
      ?+  -.sign  `this
          %watch-ack
        ?~  p.sign
          `this
        ((slog [leaf+"negative watch-ack for calendars" u.p.sign]) `this)
        ::
          %fact
        ~&  [%fact-from from]
        ?+  p.cage.sign  !!
            %ucal-update
          =/  u=update:ucal  !<  update:ucal  q.cage.sign
          ?:  ?=([%calendar-added *] u)
            ~&  [%cal-added calendar.u]
            `this
          ?:  ?=([%calendar-changed *] u)
            ~&  [%cal-changed calendar.u]
            `this
          ?:  ?=([%calendar-removed *] u)
            ~&  [%cal-removed calendar-code.u]
            `this
          !!
          ::
            %ucal-initial
          =/  =initial:ucal  !<  initial:ucal  q.cage.sign
          ?:  ?=([%calendars *] initial)
            ~&  [%cal-initial calendars.initial]
            `this
          !!
        ==
      ==
    ::
        [%events %bycal @tas ~]
      =/  from=ship  (slav %p i.t.t.wire)
      ?+  -.sign  `this
          %watch-ack
        ?~  p.sign
          `this
        ((slog [leaf+"negative watch-ack for events" u.p.sign]) `this)
        ::
          %fact
        ~&  [%fact-from from]
        ?+  p.cage.sign  !!
            %ucal-update
          =/  u=update:ucal  !<  update:ucal  q.cage.sign
          ?:  ?=([%event-added *] u)
            ~&  [%event-added event.u]
            `this
          ?:  ?=([%event-changed *] u)
            ~&  [%event-changed event.u]
            `this
          ?:  ?=([%event-removed *] u)
            ~&  [%event-removed event-code.u]
            `this
          !!
          ::
            %ucal-initial
          =/  =initial:ucal  !<  initial:ucal  q.cage.sign
          ?:  ?=([%events-bycal *] initial)
            ~&  [%events-initial events.initial]
            `this
          !!
        ==
      ==
    ::
        [%unsubscribe %calendars @tas ~]
      ?+  -.sign  `this
          %kick
        ~&  %calendars-kick-rec
        `this
      ==
    ::
        [%unsubscribe %events %bycal @tas ~]
      ?+  -.sign  `this
          %kick
        ~&  [%events-kick-rec t.t.t.wire]
        `this
      ==
    ==
  ++  on-arvo  on-arvo:def
  ++  on-leave  on-leave:def
  ++  on-peek  on-peek:def
  ++  on-fail   on-fail:def
--
::
::: helper door
::
|_  bowl=bowl:gall
::
++  poke-ucal-hook-action
  |=  =action:ucal-hook
  ^-  (quip card _state)
  ?-    -.action
      %subscribe-all
    =/  input  +.action
    :_  state  ~[(subscribe-to /calendars ship.input %ucal /calendars)]
  ::
      %subscribe-specific
    =/  input  +.action
    =/  pax=path  [%events %bycal calendar-code.input ~]
    :_  state  ~[(subscribe-to pax ship.input %ucal pax)]
  ::
      %unsubscribe-all
    =/  input  +.action
    :_  state
    ~[(unsubscribe-from [%unsubscribe /calendars] ship.input %ucal)]
  ::
      %unsubscribe-specific
    =/  input  +.action
    =/  pax=path  [%events %bycal calendar-code.input ~]
    :_  state  ~[(unsubscribe-from [%unsubscribe pax] ship.input %ucal)]
  ==
::  produces a %watch pass to the specified agent on the specified ship.
::  the wire is specified to be the supplied prefix with the target ship
::  appended to the end.
::
++  subscribe-to
|=  [prefix=wire =ship agent=term =path]
  ^-  card
  [%pass (snoc prefix (scot %p ship)) %agent [ship agent] %watch path]
::
++  unsubscribe-from
|=  [prefix=wire =ship agent=term]
  ^-  card
  [%pass (snoc prefix (scot %p ship)) %agent [ship agent] %leave ~]
--
