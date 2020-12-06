:: TODO:
:: - set up scry paths
:: - poke
:: - ucal.hoon -> ucal-store.hoon/calendar-store.hoon
::
/-  ucal, ucal-almanac, ucal-store, *resource
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
    ::  maintains calendar and event states
    alma=almanac
    ::  map of entity to almanac, to track almanacs pulled from remote ships
    external=(map entity almanac)
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
    ::
        %ucal-to-subscriber
      ::  this is where updates from ucal-pull-hook come through.
      =^  cards  state  (poke-ucal-to-subscriber:uc !<(to-subscriber:ucal-store vase))
      [cards this]
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    :_  this
    ~&  [%store-on-watch path]
    ::  NOTE: the store sends subscription updates on /almanac that are proxied
    ::  by ucal-push-hook. However, since these are per-calendar, there's no
    ::  initial state we want to send here.
    ?+  path  (on-watch:def path)
        [%almanac ~]  ~
    ==
  ++  on-agent
    |~  [=wire =sign:agent:gall]
    ~&  [%ucal-store-on-agent wire sign]
    (on-agent:def wire sign)
  ++  on-arvo   on-arvo:def
  ++  on-leave  on-leave:def
  ++  on-peek
    |=  =path
    ~&  [%peek-path-is path]
    ^-  (unit (unit cage))
    ?+  path
      (on-peek:def path)
    ::
        [%y @p *]
      =/  who=@p  `@p`(slav %p `@tas`+<:path)
      ?:  =(who our.bowl)
        (handle-on-peek t.t.path alma.state)
      =/  other-alma=(unit almanac)  (~(get by external.state) `entity`who)
      ?~  other-alma
        ~
      (handle-on-peek t.t.path u.other-alma)
    ==
  ++  on-fail   on-fail:def
--
::
::: helper door
::
|_  bowl=bowl:gall
::
++  get-calendar
  |=  [=path =almanac]
  ^-  (unit cal)
  ?.  =((lent path) 1)
    ~
  =/  code=calendar-code  `term`(snag 0 path)
  (~(get-calendar al almanac) code)
::
++  get-specific-event
  |=  [=path =almanac]
  ^-  (unit event)
  ?.  =((lent path) 2)
    ~
  =/  =calendar-code  `term`(snag 0 path)
  =/  =event-code  `term`(snag 1 path)
  (~(get-event al almanac) calendar-code event-code)
::
++  get-events-bycal
  |=  [=path =almanac]
  ^-  (unit (list event))
  ?.  =((lent path) 1)
    ~
  =/  code=calendar-code  `term`(snag 0 path)
  (~(get-events-bycal al almanac) code)
::
++  get-events-inrange
  |=  [=path =almanac]
  ^-  (unit [(list event) (list projected-event)])
  ?.  =((lent path) 3)
    ~
  =/  =calendar-code  `term`(snag 0 path)
  =/  [start=@da end=@da]
      %+  normalize-period
        (slav %da (snag 1 path))
      (slav %da (snag 2 path))
  (~(get-events-inrange al almanac) calendar-code start end)
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
      %:  cal                                             :: new calendar
        our.bowl                                          :: ship
        (fall calendar-code.input (make-uuid eny.bowl 8)) :: unique code
        title.input                                       :: title
        now.bowl                                          :: created
        now.bowl                                          :: last modified
      ==
    :-  ~
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
    =/  rid=resource  (resource-for-calendar calendar-code.u.new-cal)
    =/  ts=to-subscriber:ucal-store  [rid %update %calendar-changed input now.bowl]
    =/  cag=cage  [%ucal-to-subscriber !>(ts)]
    :-  ~[[%give %fact ~[/almanac] cag]]
    state(alma new-alma)
    ::
      %delete-calendar
    =/  code  calendar-code.+.action
    ?<  =(~ (~(get-calendar al alma.state) code))
    ::  produce cards
    ::  kick from /events/bycal/calendar-code
    ::  give fact to /almanac
    =/  cal-update=card
        =/  rid=resource  (resource-for-calendar code)
        =/  removed=to-subscriber:ucal-store  [rid %update %calendar-removed code]
        [%give %fact ~[/almanac] %ucal-to-subscriber !>(removed)]
    :-  ~[cal-update]
    %=  state
      alma  (~(delete-calendar al alma.state) code)
    ==
    ::
      %create-event
    =/  input  +.action
    =/  =about:ucal  [our.bowl now.bowl now.bowl]
    =/  new=event
      %:  event
        %:  event-data
          (fall event-code.input (make-uuid eny.bowl 8))
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
    =/  paths=(list path)  ~[/almanac]
    =/  rid=resource  (resource-for-calendar calendar-code.input)
    =/  ts=to-subscriber:ucal-store  [rid %update %event-added new]
    :-  [%give %fact paths %ucal-to-subscriber !>(ts)]~
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
    =/  rid=resource  (resource-for-calendar calendar-code.patch.input)
    =/  ts=to-subscriber:ucal-store  [rid %update %event-changed input now.bowl]
    :-
    ~[[%give %fact ~[/almanac] %ucal-to-subscriber !>(ts)]]
    state(alma new-alma)
    ::
      %delete-event
    =/  cal-code  calendar-code.+.action
    =/  event-code  event-code.+.action
    =/  rid=resource  (resource-for-calendar cal-code)
    =/  ts=to-subscriber:ucal-store  [rid %update %event-removed cal-code event-code]
    :-
    ~[[%give %fact ~[/almanac] %ucal-to-subscriber !>(ts)]]
    state(alma (~(delete-event al alma.state) event-code cal-code))
    ::
      %change-rsvp
    =/  input=rsvp-change:ucal-store  +.action
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-rsvp al alma.state) input)
    ?~  new-event
      `state
    =/  rid=resource  (resource-for-calendar calendar-code.input)
    =/  ts=to-subscriber:ucal-store  [rid %update %rsvp-changed input]
    :-
    ~[[%give %fact ~[/almanac] %ucal-to-subscriber !>(ts)]]
    state(alma new-alma)
    ::
      %import-from-ics
    =/  input  +.action
    =/  [cal=calendar events=(list event)]
        %:  vcal-to-ucal
          (calendar-from-file:ucal-parser path.input)
          (make-uuid eny.bowl 8)
          our.bowl
          now.bowl
        ==
    :-  ~
    %=  state
      alma  (~(add-events al (~(add-calendar al alma.state) cal)) events)
    ==
  ==
::  +poke-ucal-to-subscriber: handler for %ucal-to-subscriber pokes
::
++  poke-ucal-to-subscriber
  |=  ts=to-subscriber:ucal-store
  ^-  (quip card _state)
  ~&  [%got-to-sub ts]
  ::  TODO do we want to produce cards for these? I don't think so.
  :-  ~
  =/  from=entity  entity.resource.ts
  =/  old-alma=almanac  (~(gut by external.state) from *almanac)
  ?-  +<.ts
      %initial
    ::  shouldn't be any state
    ?>  =(old-alma *almanac)
    =/  old-alma=almanac  (~(add-calendar al old-alma) calendar.ts)
    %=  state
      external  (~(put by external.state) from (~(add-events al old-alma) events.ts))
    ==
  ::
      %update
    ::  in every case here we're generating a new almanac
    =/  new-alma=almanac
        ?-  -.update.ts
            %calendar-changed
          %-  tail
          (~(update-calendar al old-alma) calendar-patch.update.ts modify-time.update.ts)
        ::
            %calendar-removed
          (~(delete-calendar al old-alma) calendar-code.update.ts)
        ::
            %event-added
          (~(add-event al old-alma) event.update.ts)
        ::
            %event-changed
          %-  tail
          (~(update-event al old-alma) event-patch.update.ts modify-time.update.ts)
        ::
            %event-removed
          (~(delete-event al old-alma) event-code.update.ts calendar-code.update.ts)
        ::
            %rsvp-changed
          %-  tail
          (~(update-rsvp al old-alma) rsvp-change.update.ts)
        ==
    %=  state
      external  (~(put by external.state) from new-alma)
    ==
  ==
::  +handle-on-peek: handles scries for a particular almanac
::
++  handle-on-peek
  |=  [=path =almanac]
  ^-  (unit (unit cage))
  ?+  path  [~ ~] :: unhandled
  ::
      :: y the y???
      :: Alright, so the y seems to correspond to whether the last piece
      :: of the path is seen here. if we make a %gx scry with /a/b/c, we get
      :: /x/a/b as our path, while with %gy we get /x/a/b/c
      [%almanac ~]
    ``noun+!>(almanac)
  ::
      [%calendars ~]
    ``noun+!>((~(get-calendars al almanac)))
  ::
      [%events ~]
    ``noun+!>((~(get-events al almanac)))
  ::
      [%calendars *]
    =/  res  (get-calendar t.path almanac)
    ?~  res
      ~
    ``noun+!>(u.res)
  ::
      [%events %specific *]
    =/  res  (get-specific-event t.t.path almanac)
    ?~  res
      ~
    ``noun+!>(u.res)
  ::
      [%events %bycal *]
    =/  res  (get-events-bycal t.t.path almanac)
    ?~  res
      ~
    ``noun+!>(u.res)
  ::
      [%events %inrange *]
    =/  res  (get-events-inrange t.t.path almanac)
    ?~  res
      ~
    ``noun+!>(u.res)
  ==
::  +resource-for-calendar: get resource for a given calendar
::
++  resource-for-calendar
  |=  =calendar-code
  ^-  resource
  `resource`[our.bowl `term`calendar-code]
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
