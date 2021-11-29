/-  ucal, ucal-sync
/+  default-agent
|%
+$  card  card:agent:gall
::
+$  per-cal-state  [url=tape timeout=@dr]
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
|_  =bowl:gall
+*  this  .
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
  |=  in-poke-data=cage
  ^-  (quip card _this)
  !!
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
  !!
::
++  on-fail  on-fail:def
--
