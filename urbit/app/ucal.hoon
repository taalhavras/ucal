:: TODO:
:: - set up scry paths
:: - poke
:: - ucal.hoon -> ucal-store.hoon/calendar-store.hoon
::
/-  ucal
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
::
+$  state-zero
  $:  cals=(map @tas cal)
      events=(jar @tas event)
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
::
::: gall agent definition
::
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this  .                                           :: the agent itself
      uc    ~(. +> bowl)                                :: helper core
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
        %ucal-action
      =^  cards  state  (poke-ucal-action:uc !<(action:ucal vase))
      [cards this]
    ==
  ::
  ++  on-watch  on-watch:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:def
  ++  on-leave  on-leave:def
  ++  on-peek
    |=  =path
    ~&  [%path-is path]
    ^-  (unit (unit cage))
    ?+  path
      (on-peek:def path)
    ::
        :: y the y???
        :: Alright, so the y seems to correspond to whether the last piece
        :: of the path is seen here. if we make a %gx scry with /a/b/c, we get
        :: /x/a/b as our path, while with %gy we get /x/a/b/c
        [%y %calendars ~]
      ``noun+!>((get-calendars:uc t.t.path))
    ::
        [%y %events ~]
      ``noun+!>((get-events:uc t.t.path))
    ::
        [%y %calendars *]
      ``noun+!>((get-calendar:uc t.t.path))
    ::
        [%y %events %specific *]
      ``noun+!>((get-specific-event:uc t.t.t.path))
    ::
        [%y %events %bycal *]
      ``noun+!>((get-events-bycal:uc t.t.t.path))
    ==
  ++  on-fail   on-fail:def
--
::
::: helper door
::
|_  bowl=bowl:gall
::
++  get-calendar
  |=  =path
  ^-  (unit cal)
  ?.  =((lent path) 1)
    ~
  =/  code=@tas  (snag 0 path)
  (~(get by cals.state) code)
::
++  get-specific-event
  |=  =path
  ^-  (unit event)
  ~&  [%specific-event-path path]
  ?.  =((lent path) 1)
    ~
  =/  code=@tas  (snag 0 path)
  ::  TODO I guess we could flatten, but seems expensive
  =/  events=(list (list event))
      %+  turn  ~(tap by events.state)
      tail
  |-
  ?~  events
    ~
  =/  l=(list event)  i.events
  |-
  ?~  l
    ^$(events t.events)
  ?:  =(code.i.l code)
    `i.l
  $(l t.l)
::
++  get-events-bycal
  |=  =path
  ^-  (list event)
  ~&  [%bycal-path path]
  ?.  =((lent path) 1)
    ~
  =/  code=@tas  (snag 0 path)
  (~(get ja events.state) code)
::
++  get-calendars
  |=  =path
  ^-  calendars
  %+  turn  ~(tap by cals.state)
  tail
::
++  get-events
  |=  =path
  ^-  events:ucal
  %-  zing  ::  flattens list
  (turn ~(tap by events.state) tail)
::
::  Handler for '%ucal-action' pokes
::
++  poke-ucal-action
  |=  =action:ucal
  ^-  (quip card _state)
  ?-    -.action
      %create-calendar
    :: TODO: Move to helper core
    =/  input  +.action
    =/  new=cal
      %:  cal                                           :: new calendar
        our.bowl                                        :: ship
        code.input                                      :: unique code
        title.input                                     :: title
        timezone.input                                  :: timezone
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    ?<  (~(has by cals.state) code.input)               :: error if exists
    :-  ~                                               :: no cards yet
    %=  state
      cals  (~(put by cals.state) code.input new)
    ==
    ::
      %delete-calendar
    :: TODO: Move to helper core
    =/  code  code.+.action
    ?>  (~(has by cals.state) code)
    :: TODO: kick subscribers
    :-  ~
    %=  state
      :: TODO: delete events
      cals  (~(del by cals.state) code)
    ==
    ::
      %create-event
    :: TODO: Move to helper core
    =/  input  +.action
    =/  end=@da
      ?-    -.end.input
          %end
        +.end.input
          %span
        (add +.end.input start.input)
      ==
    =/  p  (period start.input end)
    =/  new=event
      %:  event
        our.bowl
        calendar.input
        code.input                                      :: TODO: generate
        title.input
        -.p                                             :: start
        +.p                                             :: end
        description.input
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    ?>  (~(has by cals.state) calendar.input)           :: calendar exists
    ::    :: TODO: give %fact to subscribers
    :-  ~                                               :: no cards yet
    %=  state
      events  (~(add ja events.state) calendar.input new)
    ==
    ::
      %delete-event
    =/  code  code.+.action
    =/  l=(list [@tas (list event)])  ~(tap by events.state)
    |-
    ?~  l
      [~ state]  :: no changes, deleting nonexistent event
    =/  events=(list event)  +:i.l
    =/  [kept=(list event) gone=(list event)]
        %+  skid  +:i.l
        |=(e=event =(code code.e))
    ?~  gone
      $(l t.l)
    ?>  =((lent gone) 1)
    :-
    ~
    state(events (~(put by events.state) -:i.l kept))

  ==
::
:: period of time, properly ordered
::
++  period
  |=  [a=@da b=@da]
  ^-  [@da @da]
  ?:  (lth b a)
    [b a]
  [a b]
--
