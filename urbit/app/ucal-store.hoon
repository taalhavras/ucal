:: TODO:
:: - set up scry paths
:: - poke
:: - ucal.hoon -> ucal-store.hoon/calendar-store.hoon
::
/-  ucal, ucal-almanac, ucal-store
/+  default-agent, *ucal-util, alma-door=ucal-almanac, ucal-parser
::
::: local type
::
|%
:: aliases
+$  card   card:agent:gall
+$  cal    calendar:ucal
+$  event  event:ucal
+$  event-data  event-data:ucal
+$  projected-event  projected-event:ucal
+$  calendar-code  calendar-code:ucal
+$  event-code  event-code:ucal
+$  almanac  almanac:ucal-almanac
++  al  al:alma-door
::
+$  state-zero
  $:
    alma=almanac ::  maintains calendar and event states
    cal-code=calendar-code ::  for generating calendar codes
    event-codes=(map calendar-code event-code) ::  for generating event codes
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
      =^  cards  state  (poke-ucal-action:uc !<(action:ucal-store vase))
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
      ^-  initial:ucal-store
      [%calendars (~(get-calendars al alma.state))]
    ::
        [%events %bycal *]
      %+  give  %ucal-initial
      ^-  initial:ucal-store
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
      ``noun+!>((~(get-calendars al alma.state)))
    ::
        [%y %events ~]
      ``noun+!>((~(get-events al alma.state)))
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
    ::
        [%y %events %inrange *]
      ~&  [%inrange t.t.t.path]
      =/  res  (get-events-inrange:uc t.t.t.path)
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
  =/  code=calendar-code  (cord-to-cc (snag 0 path))
  (~(get-calendar al alma.state) code)
::
++  get-specific-event
  |=  =path
  ^-  (unit event)
  ~&  [%specific-event-path path]
  ?.  =((lent path) 2)
    ~
  =/  =calendar-code  (cord-to-cc (snag 0 path))
  =/  =event-code  (cord-to-ec (snag 1 path))
  (~(get-event al alma.state) calendar-code event-code)
::
++  get-events-bycal
  |=  =path
  ^-  (unit (list event))
  ~&  [%bycal-path path]
  ?.  =((lent path) 1)
    ~
  =/  code=calendar-code  (cord-to-cc (snag 0 path))
  (~(get-events-bycal al alma.state) code)
::
++  get-events-inrange
  |=  =path
  ^-  (unit [(list event) (list projected-event)])
  ?.  =((lent path) 3)
    ~
  =/  =calendar-code  (cord-to-cc (snag 0 path))
  =/  [start=@da end=@da]
      %+  normalize-period
        (slav %da (snag 1 path))
      (slav %da (snag 2 path))
  (~(get-events-inrange al alma.state) calendar-code start end)
::
::  Handler for '%ucal-action' pokes
::
++  poke-ucal-action
  |=  =action:ucal-store
  ^-  (quip card _state)
  ?-    -.action
      %create-calendar
    =/  input  +.action
    =/  new=cal
      %:  cal                                           :: new calendar
        our.bowl                                        :: ship
        cal-code.state                                  :: unique code
        title.input                                     :: title
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    ?>  =(~ (~(get-calendar al alma.state) cal-code.state)) :: error if exists
    =/  paths=(list path)  ~[/calendars]
    =/  u=update:ucal-store  [%calendar-added new]
    =/  v=vase  !>(u)
    =/  cag=cage  [%ucal-update v]
    =/  c=card  [%give %fact paths cag]
    :-  ~[c]
    %=  state
      alma  (~(add-calendar al alma.state) new)
      cal-code  +(cal-code.state)
      event-codes  (~(put by event-codes.state) cal-code.state 0)
    ==
    ::
      %update-calendar
    =/  input  +.action
    =/  [new-cal=(unit cal) new-alma=almanac]
        (~(update-calendar al alma.state) input now.bowl)
    ?~  new-cal
      ::  nonexistant update
      `state
    =/  cag=cage  [%ucal-update !>(`update:ucal-store`[%calendar-changed u.new-cal])]
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
        =/  removed=update:ucal-store  [%calendar-removed code]
        [%give %fact ~[/calendars] %ucal-update !>(removed)]
    =/  kick-subs=card
        [%give %kick ~[(snoc `path`/events/bycal (cc-to-cord code))] ~]
    :-  ~[cal-update kick-subs]
    %=  state
      alma  (~(delete-calendar al alma.state) code)
      event-codes  (~(del by event-codes.state) code)
    ==
    ::
      %create-event
    =/  input  +.action
    =/  =about:ucal  [our.bowl now.bowl now.bowl]
    ::  generate new event code
    =/  cur-code=(unit event-code)  (~(get by event-codes.state) calendar-code.input)
    ?~  cur-code
      ::  nonexistent calendar
      ::  FIXME do we want to just use got above and crash?
      `state
    =/  new=event
      %:  event
        %:  event-data
          u.cur-code
          calendar-code.input
          about
          detail.input
          when.input
          invites.input
          %yes  :: organizer is attending own event by default
          tzid.input
        ==
        era.input
      ==
    :: calendar must exist
    ?<  =(~ (~(get-calendar al alma.state) calendar-code.input))
    =/  paths=(list path)  ~[(snoc `path`/events/bycal (cc-to-cord calendar-code.input))]
    :-  [%give %fact paths %ucal-update !>(`update:ucal-store`[%event-added new])]~
    %=  state
      alma  (~(add-event al alma.state) new)
      event-codes  (~(put by event-codes.state) calendar-code.input +(u.cur-code))
    ==
    ::
      %update-event
    =/  input  +.action
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-event al alma.state) input now.bowl)
    ?~  new-event
      `state  :: nonexistent update
    =/  u=update:ucal-store  [%event-changed u.new-event]
    =/  pax=path  (snoc `path`/events/bycal (cc-to-cord calendar-code.patch.input))
    :-
    ~[[%give %fact ~[pax] %ucal-update !>(u)]]
    state(alma new-alma)
    ::
      %delete-event
    =/  cal-code  calendar-code.+.action
    =/  event-code  event-code.+.action
    =/  u=update:ucal-store  [%event-removed event-code]
    :-
    ~[[%give %fact ~[(snoc `path`/events/bycal (cc-to-cord cal-code))] %ucal-update !>(u)]]
    state(alma (~(delete-event al alma.state) event-code cal-code))
    ::
      %change-rsvp
    =/  input  +.action
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-rsvp al alma.state) input)
    ?~  new-event
      `state
    =/  u=update:ucal-store  [%event-changed u.new-event]
    =/  pax=path  (snoc `path`/events/bycal (cc-to-cord calendar-code.rsvp-change.input))
    :-
    ~[[%give %fact ~[pax] %ucal-update !>(u)]]
    state(alma new-alma)
    ::
      %import-from-ics
    =/  input  +.action
    =/  [cal=calendar events=(list event)]
        %:  vcal-to-ucal
          (calendar-from-file:ucal-parser path.input)
          cal-code.state
          our.bowl
          now.bowl
        ==
    =/  [new-alma=almanac next-event-code=event-code]
        %-  tail :: only care about state produced in spin, not list
        %^  spin  events
          [(~(add-calendar al alma.state) cal) `event-code`0]
        |=  [e=event alma=almanac code=event-code]
        ^-  [event almanac event-code]
        [e (~(add-event al alma) e) +(code)]
    :-  ~[[%give %fact ~[/calendars] [%ucal-update !>(`update:ucal-store`[%calendar-added cal])]]]
    %=  state
      alma  new-alma
      cal-code  +(cal-code.state)
      event-codes  (~(put by event-codes.state) cal-code.state next-event-code)
    ==
  ==
::
:: period of time, properly ordered
::
++  normalize-period
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
