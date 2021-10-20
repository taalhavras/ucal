/-  *iana-components, timezone-store
/+  default-agent, iana-parser, parser-util
::
::: local type
::
|%
:: aliases
+$  card   card:agent:gall
::
+$  state-zero
  $:  zones=(map @t zone)
      rules=(map @t tz-rule)
      links=(map @t @t)
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
    ::
        %timezone-store-action
      =^  cards  state  (poke-handler:hc !<(action:timezone-store vase))
      [cards this]
    ==
  ::
  ++  on-watch  on-watch:def
  ++  on-agent  on-agent:def
  ++  on-arvo   on-arvo:def
  ++  on-leave  on-leave:def
  ++  on-peek
    |=  =path
    ~&  [%peek-path-is path]
    ^-  (unit (unit cage))
    ?+  path
      (on-peek:def path)
    ::
        [%x %rules name=@ta ~]
      ``noun+!>((lookup-rule i.t.t.path))
    ::
        [%x %zones name=@ta ~]
      ``noun+!>((lookup-zone i.t.t.path))
    ==
  ++  on-fail   on-fail:def
--
::
::: helper door
::
|_  bowl=bowl:gall
++  poke-handler
  |=  =action:timezone-store
  ^-  (quip card _state)
  ?:  ?=([%import-files *] action)
    :-  ~
    |-
    ?~  files.action
      state
    $(files.action t.files.action, state (import-single-file i.files.action))
  !!
::
++  import-single-file
  |=  pax=path
  ^-  _state
  =/  [zones=(map @t zone) rules=(map @t tz-rule) links=(map @t @t)]
      (parse-timezones:iana-parser (read-file:parser-util pax))
  %=  state
    zones  (~(uni by zones.state) zones)
    rules  (~(uni by rules.state) rules)
    links  (~(uni by links.state) links)
  ==
::
++  lookup-rule
  |=  key=@t
  ^-  tz-rule
  (~(got by rules.state) key)
::
++  lookup-zone
  |=  key=@t
  ^-  zone
  ::  As it stands, this doesn't allow multiple key chains. This is
  ::  simple enough to change but does allow infinite loops with link
  ::  cycles. Since the docs don't mention if links more than 1 deep
  ::  are allowed, we won't support them.
  =/  linked=(unit @t)  (~(get by links.state) key)
  %-  ~(got by zones.state)
  (fall linked key)
--
