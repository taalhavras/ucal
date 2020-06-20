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
      events=(map @tas events:ucal)
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
  ++  on-load
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
    ?+  path  (on-peek:def path)
        :: y the y???
        [%y %calendars ~]
      ``noun+!>((get-calendars:uc t.t.path))
        [%y %events *]
      ``noun+!>((get-events:uc t.t.path))
    ==
  ++  on-fail   on-fail:def
--
::
::: helper door
::
|_  bowl=bowl:gall
++  get-calendars
  |=  =path
  ^-  calendars
  %+  turn  ~(tap by cals.state)
  tail
++  get-events
  |=  =path
  ^-  events:ucal
  ~
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
      events  (~(put by events.state) calendar.input new)
    ==
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
