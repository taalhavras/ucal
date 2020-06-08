/-  ucal
/+  default-agent
::
::: local types
::
|%
+$  card  card:agent:gall                               :: alias for convenience
+$  cal   calendar:ucal
::
+$  state-zero
  $:  cals=(map @tas cal)
      events=(map @ @)
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
      %new-calendar
    =/  input  +.action
    =/  now  now.bowl
    =/  new=cal
      (cal our.bowl code.input title.input now now)
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
    ::
      %new-event
    ~&  +.action
    [~ state]
  ==
--
