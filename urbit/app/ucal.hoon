/-  ucal
/+  default-agent
::
::: local types
::
|%
:: aliases
+$  card   card:agent:gall
+$  cal    calendar:ucal
+$  event  event:ucal
::
+$  state-zero
  $:  cals=(map @tas cal)
      events=(list event)
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
  ++  on-peek   on-peek:def
  ++  on-fail   on-fail:def

--
::
::: helper door
::
|_  bowl=bowl:gall
::
::  Handler for '%ucal-action' pokes
::
++  poke-ucal-action
  |=  =action:ucal
  ^-  (quip card _state)
  ?-    -.action
      %create-calendar
    =/  input  +.action
    =/  new=cal
      %:  cal                                           :: new calendar
        our.bowl                                        :: ship
        code.input                                      :: unique code
        title.input                                     :: title
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
    =/  code  code.+.action
    ?>  (~(has by cals.state) code)
    :-  ~
    %=  state
      :: TODO: delete events
      cals  (~(del by cals.state) code)
    ==
    ::
      %create-event
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
    :-  ~                                               :: no cards yet
    %=  state
      events  new^events.state
    ==
    ::
    :: doesn't belong as a poke, but will be helpful for testing
      %query-events
    =/  input  +.action
    ~&  [-.action input]
    [~ state]
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
