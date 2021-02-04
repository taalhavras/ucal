/-  ucal, ucal-almanac, ucal-store, *resource
/+  default-agent, *ucal-util, alma-door=ucal-almanac, ucal-parser, tzconv=iana-conversion
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
  $:  ::  maintains calendar and event states
      alma=almanac
      ::  map of entity to almanac, to track almanacs pulled from remote ships
      external=(map entity almanac)
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
        [%x @p *]
      =/  who=@p  `@p`(slav %p `@tas`+<:path)
      ?:  =(who our.bowl)
        (handle-on-peek bowl t.t.path alma.state)
      =/  other-alma=(unit almanac)  (~(get by external.state) `entity`who)
      ?~  other-alma
        ~
      (handle-on-peek bowl t.t.path u.other-alma)
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
    ::  only the ship (or a moon) ucal-store is running on can create new calendars
    ?>  (team:title [our src]:bowl)
    =/  input  +.action
    =/  new=cal
      :*
        our.bowl                                          :: ship
        (fall calendar-code.input (make-uuid eny.bowl 8)) :: unique code
        title.input                                       :: title
        permissions.input                                 :: permissions
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
      ::  updating nonexistant calendar
      `state
    ::  now verify that this ship actually had permissions to edit
    ::  the calendar in question before updating our almanac. since
    ::  the permissions can't be updated in this path it's fine to
    ::  check after applying the update.
    ?>  (can-write-cal [owner permissions]:u.new-cal src.bowl)
    =/  rid=resource  (resource-for-calendar calendar-code.u.new-cal)
    =/  ts=to-subscriber:ucal-store  [rid %update %calendar-changed input now.bowl]
    =/  cag=cage  [%ucal-to-subscriber !>(ts)]
    :-  ~[[%give %fact ~[/almanac] cag]]
    state(alma new-alma)
    ::
      %delete-calendar
    ::  only the ship (or a moon) ucal-store is running on can delete calendars
    ?>  (team:title [our src]:bowl)
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
    =/  target=(unit cal)  (~(get-calendar al alma.state) calendar-code.input)
    ::  target calendar must exist
    ?~  target
      !!
    ::  must have write access to calendar to create an event
    ?>  (can-write-cal [owner permissions]:u.target src.bowl)
    =/  =about:ucal  [our.bowl now.bowl now.bowl]
    =/  new=event
      :*
        ^-  event-data
        :*
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
    =/  target=(unit cal)
        (~(get-calendar al alma.state) calendar-code.patch.input)
    ::  target calendar must exist
    ?~  target
      !!
    ::  must have write access to calendar to update an event
    ?>  (can-write-cal [owner permissions]:u.target src.bowl)
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
    =/  target=(unit cal)
        (~(get-calendar al alma.state) cal-code)
    ::  target calendar must exist
    ?~  target
      !!
    ::  must have write access to calendar to delete an event
    ?>  (can-write-cal [owner permissions]:u.target src.bowl)
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
    ::  only the ship (or a moon) ucal-store is running on can import calendars
    ?>  (team:title our.bowl src.bowl)
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
    ::
      %change-permissions
    =/  input=permission-change:ucal-store  +.action
    =/  cc=calendar-code  calendar-code.input
    =/  target=cal  (need (~(get-calendar al alma.state) cc))
    ::  whoever is changing permissions must be an acolyte or the owner
    ?>  (can-change-permissions [owner permissions]:target src.bowl)
    =/  updated=calendar-permissions
        (apply-permissions-update permissions.target input)
    =/  rid=resource  (resource-for-calendar cc)
    =/  ts=to-subscriber:ucal-store  [rid %update %permissions-changed cc updated]
    :-  ~[[%give %fact ~[/almanac] %ucal-to-subscriber !>(ts)]]
    %=  state
      alma  (~(add-calendar al alma.state) target(permissions updated))
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
    ::  shouldn't be any state for this calendar prior to the update.
    ?>  =(~ (~(get-calendar al old-alma) calendar-code.calendar.ts))
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
        ::
            %permissions-changed
          =/  target=cal
              (need (~(get-calendar al old-alma) calendar-code.update.ts))
          =/  new-permissions=calendar-permissions
              calendar-permissions.update.ts
          (~(add-calendar al old-alma) target(permissions new-permissions))
        ==
    %=  state
      external  (~(put by external.state) from new-alma)
    ==
  ==
::  +handle-on-peek: handles scries for a particular almanac
::
++  handle-on-peek
  |=  [=bowl:gall =path =almanac]
  ^-  (unit (unit cage))
  ?+  path  [~ ~] :: unhandled
  ::
      [%almanac ~]
    ``ucal-almanac+!>(almanac)
  ::
      [%calendars ~]
    ``ucal-calendars+!>((~(get-calendars al almanac)))
  ::
      [%events ~]
    ``ucal-events+!>((~(get-events al almanac)))
  ::
      [%calendars *]
    =/  res  (get-calendar t.path almanac)
    ?~  res
      ~
    ``ucal-calendar+!>(u.res)
  ::
      [%events %specific *]
    =/  res  (get-specific-event t.t.path almanac)
    ?~  res
      ~
    ``ucal-event+!>(u.res)
  ::
      [%events %bycal *]
    =/  res  (get-events-bycal t.t.path almanac)
    ?~  res
      ~
    ``ucal-events+!>(u.res)
  ::
      [%events %inrange *]
    =/  res  (get-events-inrange t.t.path almanac)
    ?~  res
      ~
    ``ucal-events-in-range+!>(u.res)
  ::
      [%timezone @t %events @t *]
    ~&  %specific-timezone-case
    =/  tzid=@t  i.t.path
    =/  variant=@t  i.t.t.t.path
    =/  convert-event-data=$-(event-data event-data)
        |=  ed=event-data
        ^-  event-data
        =/  src-zone=@ta  (crip tzid.ed)
        =/  [start=@da @da]  (moment-to-range when.ed)
        =/  new-start=@da
            (~(convert-between tzconv [our.bowl now.bowl]) start src-zone tzid)
        ed(when (move-moment-start when.ed new-start), tzid (trip tzid))
    ::  now we support the same scrys we do earlier
    ?:  =(variant %specific)
      =/  res=(unit event)  (get-specific-event t.t.t.t.path almanac)
      ?~  res
        ~
      ``ucal-event+!>(u.res(data (convert-event-data data.u.res)))
    ?:  =(variant %bycal)
      =/  res=(unit (list event))  (get-events-bycal t.t.path almanac)
      ?~  res
        ~
      %-  some
      %-  some
      :-  %ucal-events
      !>
      %+  turn
        u.res
      |=  ev=event
      ^-  event
      ev(data (convert-event-data data.ev))
    ?:  =(variant %inrange)
      =/  res=(unit [(list event) (list projected-event)])  (get-events-inrange t.t.path almanac)
      ?~  res
        ~
      %-  some
      %-  some
      :-  %ucal-events-in-range
      !>
      :-
        %+  turn
          -.u.res
        |=  ev=event
        ^-  event
        ev(data (convert-event-data data.ev))
      %+  turn
        +.u.res
      |=  pr=projected-event
      ^-  projected-event
      pr(data (convert-event-data data.pr))
    !!
  ==
::  +apply-permissions-update: updates calendar permissions
::
++  apply-permissions-update
  |=  [old-permissions=calendar-permissions =permission-change:ucal-store]
  ^-  calendar-permissions
  =/  change  +.permission-change
  ?-    -.change
      %change
    (set-permissions old-permissions who.change role.change)
  ::
      %make-public
    old-permissions(readers ~)
  ::
      %make-private
    old-permissions(readers [~ ~])
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
--
