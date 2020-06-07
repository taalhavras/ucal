/-  ucal
/+  default-agent
::
::: local types
::
|%
+$  card  card:agent:gall                               :: alias for convenience
::
+$  state-zero  cals=(map @tas calendar:ucal)
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
  ++  on-init
    ^-  (quip card _this)
    :_  this
    :: use of this rune is overkill, unless we do more in the future, e.g.
    :: - connect to clay and read ics files
    :: - set up a landscape tile
    :~
      :: set up connection to Eyre for future
      [%pass /bind %arvo %e %connect [~ /'~calendar'] %calendar]
    ==
  --
  ::
  ++  on-save
    ^-  vase
    !>(state)
  ::
  ++  on-load
    |=  =vase
    ^-  (quip card _this)
    :-  ~                                               :: no cards to emit
    =/  prev  !<(versioned-state)
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
      =^  cards  state  (poke-ucal-action:rc !<(action:ucal vase))
      [cards this]
    ::
        %handle-http-request
      :_  this
      =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
      %+  give-simple-payload:app:server    eyre-id
      %+  require-authorization:app:server  inbound-request
      poke-handle-http-request:rc
    ==
  ::
  ++  on-watch  on-watch:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:dev
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
    ~&  +.action
    [~ state]
      %new-event
    ~&  +.action
    [~ state]
  ==
--


:: NOTES ===========
:: https://urbit.org/docs/reference/vane-apis/gall/
:: App can be poked in the dojo by running the following commands
:: Increment local counter
:: :example-gall &example-gall-action [%increment ~]
:: Increment ~zod's counter
:: :example-gall &example-gall-action [%increment-remote ~zod]
:: Subscribe to ~zod's counter
:: :example-gall &example-gall-action [%view ~zod]
:: Unsubscribe from ~zod's counter
:: :example-gall &example-gall-action [%stop-view ~zod]
