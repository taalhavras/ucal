:: TODO:
:: - set up scry paths
:: - poke
:: - ucal.hoon -> ucal-store.hoon/calendar-store.hoon
::
/-  ucal, *ucal-almanac
/+  default-agent
::
::: local type
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
  $:  alma=almanac
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
  (~(get-calendar al state) code)
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
  (~(get-events-bycal al alma.state) code)
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
  (~(get-events al alma.state))
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
        calendar-code.input                             :: unique code
        title.input                                     :: title
        (fall timezone.input 'utc')                     :: timezone
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    ?>  =(~ (~(get-calendar al alma.state) calendar-code.input)) :: error if exists
    =/  paths=(list path)  ~[/calendars]
    =/  u=update:ucal  [%calendar-added new]
    =/  v=vase  !>(u)
    =/  cag=cage  [%ucal-update v]
    =/  c=card  [%give %fact paths cag]
    :-  ~[c]
    %=  state
      alma  (~(add-calendar al alma.state) new)
    ==
    ::
      %update-calendar
    =/  input  +.action
    =/  [new-cal=(unit cal) new-alma=almanac]
        (~(update-calendar al alma.state) input now.bowl)
    ?~  new-cal
      ::  nonexistant update
      `state
    =/  cag=cage  [%ucal-update !>(`update:ucal`[%calendar-changed u.new-cal])]
    :-  ~[[%give %fact ~[/calendars] cag]]
    state(alma new-alma)
    ::
      %delete-calendar
    =/  code  calendar-code.+.action
    ?<  =(~ (~(get-calendar al alma.state) code))
    ::  produce cards
    ::  kick from /events/bycal/calendar-code
    ::  give fact to /calendars
    =/  cal-update=card
        =/  removed=update:ucal  [%calendar-removed code]
        [%give %fact ~[/calendars] %ucal-update !>(removed)]
    =/  kick-subs=card
        [%give %kick ~[(snoc `path`/events/bycal code)] ~]
    :-  ~[cal-update kick-subs]
    %=  state
      alma  (~(delete-calendar al alma.state) code)
    ==
    ::
      %create-event
    =/  input  +.action
    =/  p  (period-from-dur start.input end.input)
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
        ~
      ==
    :: calendar must exist
    ?<  =(~ (~(get-calendar al alma.state) calendar-code.input))
    =/  paths=(list path)  ~[(snoc `path`/events/bycal calendar-code.input)]
    :-  [%give %fact paths %ucal-update !>(`update:ucal`[%event-added new])]~
    %=  state
      alma  (~(add-event al alma.state) new)
    ==
    ::
      %update-event
    =/  input  +.action
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-event al alma.state) input now.bowl)
    ?~  new-event
      `state  :: nonexistent update
    =/  u=update:ucal  [%event-changed u.new-event]
    =/  pax=path  (snoc `path`/events/bycal calendar-code.patch.input)
    :-
    ~[[%give %fact ~[pax] %ucal-update !>(u)]]
    state(alma new-alma)
    ::
      %delete-event
    =/  cal-code  calendar-code.+.action
    =/  event-code  event-code.+.action
    =/  u=update:ucal  [%event-removed event-code]
    :-
    ~[[%give %fact ~[(snoc `path`/events/bycal cal-code)] %ucal-update !>(u)]]
    state(alma (~(delete-event al alma.state) event-code cal-code))
    ::
      %change-rsvp
    =/  input  +.action
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-rsvp al alma.state) input)
    ?~  new-event
      `state
    =/  u=update:ucal  [%event-changed u.new-event]
    =/  pax=path  (snoc `path`/events/bycal calendar-code.rsvp-change.input)
    :-
    ~[[%give %fact ~[pax] %ucal-update !>(u)]]
    state(alma new-alma)
    ::
      %import-from-ics
    ::  TODO implement
    `state
  ==
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
