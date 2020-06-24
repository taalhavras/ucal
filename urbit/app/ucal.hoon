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
+$  calendar-code  calendar-code:ucal
+$  event-code  event-code:ucal
::
+$  state-zero
  $:  cals=(map calendar-code cal)
      events=(jar event-code event)
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
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    :_  this
    ::  NOTE
    ::  if we crash it terminates the subscription
    ::  (a negative watch-ack goes to the subscriber)
    ::  as it it never started.
    ?+  path
      (on-watch:def path)
    ::
        [%calendars ~]
      %+  give  %ucal-initial
      ^-  initial:ucal
      [%calendars (get-calendars:uc)]
    ::
        [%events %bycal *]
      %+  give  %ucal-initial
      ^-  initial:ucal
      [%events-bycal (need (get-events-bycal:uc t.t.path))]
    ==
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
      ``noun+!>((get-calendars:uc))
    ::
        [%y %events ~]
      ``noun+!>((get-events:uc))
    ::
        [%y %calendars *]
      =/  res  (get-calendar:uc t.t.path)
      ?~  res
        [~ ~]
      ``noun+!>(u.res)
    ::
        [%y %events %specific *]
      =/  res  (get-specific-event:uc t.t.t.path)
      ?~  res
        [~ ~]
      ``noun+!>(u.res)
    ::
        [%y %events %bycal *]
      =/  res  (get-events-bycal:uc t.t.t.path)
      ?~  res
        [~ ~]
      ``noun+!>(u.res)
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
  =/  code=calendar-code  (snag 0 path)
  (~(get by cals.state) code)
::
++  get-specific-event
  |=  =path
  ^-  (unit event)
  ~&  [%specific-event-path path]
  ?.  =((lent path) 1)
    ~
  =/  code=event-code  (snag 0 path)
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
  ?:  =(event-code.i.l code)
    `i.l
  $(l t.l)
::
++  get-events-bycal
  |=  =path
  ^-  (unit (list event))
  ~&  [%bycal-path path]
  ?.  =((lent path) 1)
    ~
  =/  code=calendar-code  (snag 0 path)
  (~(get by events.state) code)
::
++  get-calendars
  |.
  ^-  calendars
  %+  turn  ~(tap by cals.state)
  tail
::
++  get-events
  |.
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
        calendar-code.input                             :: unique code
        title.input                                     :: title
        timezone.input                                  :: timezone
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    ?<  (~(has by cals.state) calendar-code.input)      :: error if exists
    :-  ~[[%give %fact ~[/calendars] noun+!>(new)]]
    %=  state
      cals  (~(put by cals.state) calendar-code.input new)
    ==
    ::
      %delete-calendar
    :: TODO: Move to helper core
    =/  code  calendar-code.+.action
    ?>  (~(has by cals.state) code)
    ::  TODO: produce cards
    ::  kick from /events/bycal/calendar-code
    ::  give fact to /calendars
    =/  cal-update=card
        [%give %fact ~[/calendars] %ucal-update %calendar-removed code]
    =/  kick-subs=card
        [%give %kick ~[(snoc /events/bycal code)] ~]
    :-  ~[cal-update kick-subs]
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
        calendar-code.input
        event-code.input                                :: TODO: generate
        title.input
        -.p                                             :: start
        +.p                                             :: end
        description.input
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    ?>  (~(has by cals.state) calendar-code.input)      :: calendar exists
    =/  paths=(list path)  ~[/events (snoc `path`/events/bycal calendar-code.input)]
    :-  ~[[%give %fact paths noun+!>(new)]]
    %=  state
      events  (~(add ja events.state) calendar-code.input new)
    ==
    ::
      %delete-event
    =/  cal-code  calendar-code.+.action
    =/  event-code  event-code.+.action
    =/  [gone=(list event) kept=(list event)]
        %+  skid  (~(get ja events.state) cal-code)
        |=(e=event =(event-code event-code.e))
    ?~  gone
      [~ state] :: deleting nonexistant event
    ?>  =((lent gone) 1)
    :-
    ::  TODO cards for events/bycal/calendar-code
    ~
    state(events (~(put by events.state) cal-code kept))
    ::
      %change-rsvp
    =/  input  +.action
    =/  new-events=(list event)
        %+  reel :: right fold to avoid reversing list
          (~(get ja events.state) calendar-code.input)
        |=  [cur=event acc=(list event)]
        ^-  (list event)
        ?.  =(event-code.input event-code.cur)
          [cur acc]
        [cur(rsvps (~(put by rsvps.cur) who.input status.input)) acc]
    :-
    ::  TODO cards for events/bycal/calendar-code
    ~
    state(events (~(put by events.state) calendar-code.input new-events))
    ::
      %import-from-ics
    ::  TODO implement
    :-(~ state)
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
::
++  give
  |*  [=mark =noun]
  ^-  (list card)
  [%give %fact ~ mark !>(noun)]~
::
++  give-single
  |*  [=mark =noun]
  ^-  card
  [%give %fact ~ mark !>(noun)]
--
