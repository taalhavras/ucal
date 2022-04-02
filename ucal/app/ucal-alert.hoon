/-  ucal, hark-store
/+  default-agent,
::
::: local type aliases
::
|%
+$  card   card:agent:gall
+$  cal    calendar:ucal
+$  event  event:ucal
+$  event-data  event-data:ucal
+$  projected-event  projected-event:ucal
+$  calendar-code  calendar-code:ucal
+$  event-code  event-code:ucal
::
+$  state-zero
  $:
    :: store pairs for the events we've already alerted for in the last
    :: window.
    alerted-for=(set [calendar-code event-code])
  ==
::
+$  versioned-state
  $%  [%0 state-zero]
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
      hc    ~(. +> bowl)                                :: helper core
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
    ?+    mark  `this
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
    ==
  ::
  ++  on-watch  on-watch:def
  ++  on-agent  on-agent:def
  ++  on-arvo  on-arvo:def
  ++  on-leave  on-leave:def
  ++  on-peek  on-peek:def
  ++  on-fail   on-fail:def
--
::
::: helper door
::
|_  bowl=bowl:gall
++  make-card-for-event
  |=  data=event-data:ucal
  ^-  card
  =/  act=action:hark-store  [%add-note /ucal-invite-reminder [%ucal /]]
  =/  wir=wire  /ucal-alert/[calendar-code.data]/[event-code.data]
  [%pass %agent wir [our.bowl %hark-store] %poke %hark-action !>(act)]
--
