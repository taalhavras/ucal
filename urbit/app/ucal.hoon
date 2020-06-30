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
  `(~(get ja events.state) code)
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
        (fall timezone.input 'utc')                     :: timezone
        now.bowl                                        :: created
        now.bowl                                        :: last modified
      ==
    ?<  (~(has by cals.state) calendar-code.input)      :: error if exists
    =/  paths=(list path)  ~[/calendars]
    =/  u=update:ucal  [%calendar-added new]
    =/  v=vase  !>(u)
    =/  cag=cage  [%ucal-update v]
    =/  c=card  [%give %fact paths cag]
    :-  ~[c]
    %=  state
      cals  (~(put by cals.state) calendar-code.input new)
    ==
    ::
      %update-calendar
    =/  input  +.action
    =/  old=cal  (~(got by cals.state) calendar-code.input)
    =/  new-tz=timezone:ucal
        ?~  timezone.input
          timezone.old
        ?~  u.timezone.input
          'utc'
        u.u.timezone.input
    =/  new=cal
      %:  cal
        owner.old
        calendar-code.old
        (fall title.input title.old)
        new-tz
        date-created.old
        now.bowl
      ==
    =/  cag=cage  [%ucal-update !>(`update:ucal`[%calendar-changed new])]
    :-  ~[[%give %fact ~[/calendars] cag]]
    state(cals (~(put by cals.state) calendar-code.input new))
    ::
      %delete-calendar
    :: TODO: Move to helper core
    =/  code  calendar-code.+.action
    ?>  (~(has by cals.state) code)
    ::  TODO: produce cards
    ::  kick from /events/bycal/calendar-code
    ::  give fact to /calendars
    =/  cal-update=card
        =/  removed=update:ucal  [%calendar-removed code]
        [%give %fact ~[/calendars] %ucal-update !>(removed)]
    =/  kick-subs=card
        [%give %kick ~[(snoc `path`/events/bycal code)] ~]
    :-  ~[cal-update kick-subs]
    %=  state
      :: TODO: delete events
      cals  (~(del by cals.state) code)
    ==
    ::
      %create-event
    :: TODO: Move to helper core
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
    ?>  (~(has by cals.state) calendar-code.input)      :: calendar exists
    =/  paths=(list path)  ~[(snoc `path`/events/bycal calendar-code.input)]
    :-  [%give %fact paths %ucal-update !>(`update:ucal`[%event-added new])]~
    %=  state
      events  (~(add ja events.state) calendar-code.input new)
    ==
    ::
      %update-event
    =/  input  +.action
    ::  TODO get specific event
    =/  cal-code  calendar-code.input
    =/  event-code  event-code.input
    =/  [new-events=(list event) new=event]
        =/  cur-events  (~(get ja events.state) cal-code)
        =|  acc=(list event)
        |-
        ?~  cur-events
          !!
        =/  cur=event  i.cur-events
        ?.  =(event-code.input event-code.cur)
          $(acc [cur acc], cur-events t.cur-events)
        =/  p=[@da @da]
            =/  new-start  (fall start.input start.cur)
            ?~  end.input
              (period new-start end.cur)
            (period-from-dur new-start u.end.input)
        =/  new=event
            %:
              event
              owner.cur
              calendar.cur
              event-code.cur
              (fall title.input title.cur)
              -.p
              +.p
              (fall description.input description.cur)
              date-created.cur
              now.bowl
              rsvps.cur
            ==
        =/  res=(list event)  [new t.cur-events]
        |-
        ?~  acc
          [res new]
        $(res [i.acc res], acc t.acc)
    =/  u=update:ucal  [%event-changed new]
    =/  pax=path  (snoc `path`/events/bycal calendar-code.input)
    :-
    ~[[%give %fact ~[pax] %ucal-update !>(u)]]
    state(events (~(put by events.state) calendar-code.input new-events))
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
    =/  u=update:ucal  [%event-removed event-code]
    :-
    ~[[%give %fact ~[(snoc `path`/events/bycal cal-code)] %ucal-update !>(u)]]
    state(events (~(put by events.state) cal-code kept))
    ::
      %change-rsvp
    =/  input  +.action
    ::  update event with rsvp, maintains list order
    =/  [new-events=(list event) new=event]
        =/  cur-events  (~(get ja events.state) calendar-code.input)
        =|  acc=(list event)
        |-
        ?~  cur-events
          !!
        =/  cur=event  i.cur-events
        ?.  =(event-code.input event-code.cur)
          $(acc [cur acc], cur-events t.cur-events)
        =/  new=event  cur(rsvps (~(put by rsvps.cur) who.input status.input))
        =/  res=(list event)  [new t.cur-events]
        |-
        ?~  acc
          [res new]
        $(res [i.acc res], acc t.acc)
    =/  u=update:ucal  [%event-changed new]
    =/  pax=path  (snoc `path`/events/bycal calendar-code.input)
    :-
    ~[[%give %fact ~[pax] %ucal-update !>(u)]]
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
::  period of time from absolute start and dur, properly ordered
::
++  period-from-dur
  |=  [start=@da =dur:ucal]
  ^-  [@da @da]
  =/  end=@da
      ?-    -.dur
        %end  +.dur
        %span  (add +.dur start)
      ==
  (period start end)
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
