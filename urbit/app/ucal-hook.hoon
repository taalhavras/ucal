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
    ?+  wire  (on-agent:def wire sign)
        [%calendars @tas ~]
      =/  from=ship  (slav %p i.t.wire)
      ?+  -.sign  `this
          %watch-ack
        ?~  p.sign
          `this
        ((slog [leaf+"negative watch-ack for calendars" u.p.sign]) `this)
        ::
          %fact
        =/  u=update:ucal  !<  update:ucal  q.cage.sign
        ~&  [%from from]
        ?+  u  `this  ::  TODO shouldn't get to this case, maybe error?
                      ::  but that causes a type error?
            %calendar-added
          ~&  [%cal-added calendar.u]
          `this
          ::
            %calendar-changed
          ~&  [%cal-changed calendar.u]
          `this
          ::
            %calendar-removed
          ~&  [%cal-removed calendar-code.u]
          `this
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
        =/  e=event  !<  event  q.cage.sign
        ~&  [%event e]
        ~&  [%from from]
        `this
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
