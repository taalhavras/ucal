/-  ucal, ucal-almanac, ucal-store, *resource, ucal-components
/+  default-agent, *ucal-util, alma-door=ucal-almanac, ucal-parser, tzconv=iana-conversion, conv=ucal-ics-converter
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
      ::  store events we're invited to in an almanac
      invited-to=almanac
      ::  track the ship we should respond to for each event we're
      ::  invited to. This is not necessarily the organizer of the
      ::  event - we want to send our responses to the host of the
      ::  calendar.
      outgoing-rsvps=(map [calendar-code event-code] @p)
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
      ::
          %bind
        %-  (slog leaf+"ucal-store: attempting to bind /ucal-calendars-ics" ~)
        :_  this
        [%pass /bind-ucal-ics %arvo %e %connect `/ucal-ics %eyre-agent]~
      ==
    ::
        %ucal-action
      =^  cards  state  (poke-ucal-action:uc !<(action:ucal-store vase))
      [cards this]
    ::
        ?(%ucal-to-subscriber %ucal-to-subscriber-0)
      ::  this is where updates from ucal-pull-hook come through.
      =^  cards  state  (poke-ucal-to-subscriber:uc !<(to-subscriber:ucal-store vase))
      [cards this]
    ::
        %ucal-invitation
      ::  if we're invited to an event we find out through these pokes
      =^  cards  state  (poke-ucal-invitation:uc !<(invitation:ucal-store vase))
      [cards this]
    ::
        %ucal-invitation-reply
      ::
      =^  cards  state  (poke-ucal-invitation-reply:uc !<(invitation-reply:ucal-store vase))
      [cards this]
    ::
        %handle-http-response
      ::  Logic for custom HTTP handling. Here we want to expose our
      ::  public calendars as ICS files that can be retrieved via GET
      ::  requests. This cannot be done via the eyre scry interface at
      ::  this time since that requires
      =/  req  !<  (pair @ta inbound-request:eyre)  vase
      ~&  [mark req]
      =^  cards  state  (poke-http-response:uc -.req +.req)
      [cards this]
    ==
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    :_  this
    ?+    path  (on-watch:def path)
        ::  NOTE: the store sends subscription updates on /almanac that are
        ::  proxied by ucal-push-hook. However, since these are per-calendar,
        ::  there's no initial state we want to send here.
        [%almanac ~]
      ~
    ::
        [%http-response *]
      ((slog leaf+"ucal: eyre subscribed to {(spud path)}." ~) ~)
    ==
  ++  on-agent
    |~  [=wire =sign:agent:gall]
    ~&  [%ucal-store-on-agent wire sign]
    (on-agent:def wire sign)
  ++  on-arvo
    |=  [=wire =sign-arvo]
    ^-  (quip card _this)
    ?.  ?=([%bind-ucal-ics ~] wire)
      (on-arvo:def [wire sign-arvo])
    ?>  ?=([%eyre %bound *] sign-arvo)
    ?:  accepted.sign-arvo
      %-  (slog leaf+"/ucal-calendars-ics bound successfully!" ~)
      `this
    %-  (slog leaf+"ucal: Binding /ucal-calendars-ics failed!" ~)
    `this
  ++  on-leave  on-leave:def
  ++  on-peek
    |=  =path
    ~&  [%peek-path-is path]
    ^-  (unit (unit cage))
    ?+  path
      (on-peek:def path)
    ::
        [%x %host @tas @tas ~]
      ``ucal-event-host+!>((~(got by outgoing-rsvps.state) [i.t.t.path i.t.t.t.path]))
    ::
        [%x %invited-to *]
      (handle-on-peek bowl t.t.path invited-to.state)
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
    =/  cc=term  -:(make-uuid ~(. og `@`eny.bowl) 8)
    =/  new=cal
      :*
        our.bowl                                       :: ship
        (fall calendar-code.input cc)                  :: unique code
        title.input                                    :: title
        permissions.input                              :: permissions
        now.bowl                                       :: created
        now.bowl                                       :: last modified
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
    =/  cag=cage  [%ucal-to-subscriber-0 !>(ts)]
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
        [%give %fact ~[/almanac] %ucal-to-subscriber-0 !>(removed)]
    =/  uninvites=(list card)
        =|  acc=(list card)
        =/  all-events=(list event)  (need (~(get-events-bycal al alma.state) code))
        |-
        ?~  all-events
          acc
        (weld (make-uninvite-cards i.all-events) acc)
    :-  [cal-update uninvites]
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
    ::  organizer can't be an invitee
    ?<  (~(has in invited.input) src.bowl)
    =/  =about:ucal  [src.bowl now.bowl now.bowl]
    =/  ec=term  -:(make-uuid ~(. og `@`eny.bowl) 8)
    =/  new=event
      :*
        ^-  event-data
        :*
          (fall event-code.input ec)
          calendar-code.input
          about
          detail.input
          when.input
          (malt (turn ~(tap in invited.input) |=(who=@p [who ~])))
          %yes  :: organizer is attending own event by default
          tzid.input
        ==
        era.input
      ==
    =/  paths=(list path)  ~[/almanac]
    =/  rid=resource  (resource-for-calendar calendar-code.input)
    =/  ts=to-subscriber:ucal-store  [rid %update %event-added new]
    =/  invite-cards=(list card)  (make-invite-cards new &)
    :-  [[%give %fact paths %ucal-to-subscriber-0 !>(ts)] invite-cards]
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
    =/  old-event=event
        %-  need
        (~(get-event al alma.state) [calendar-code event-code]:patch.input)
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-event al alma.state) input now.bowl)
    ?~  new-event
      `state  :: nonexistent update
    =/  rid=resource  (resource-for-calendar calendar-code.patch.input)
    =/  ts=to-subscriber:ucal-store  [rid %update %event-changed input now.bowl]
    ::  we need new rsvps if the era or moment are being changed.
    =/  new-rsvp=flag
        ?|  !=(era.old-event era.u.new-event)
            !=(when.data.old-event when.data.u.new-event)
        ==
    =/  invite-cards=(list card)  (make-invite-cards u.new-event new-rsvp)
    :-  [[%give %fact ~[/almanac] %ucal-to-subscriber-0 !>(ts)] invite-cards]
    state(alma new-alma)
    ::
      %delete-event
    =/  cal-code  calendar-code.+.action
    =/  event-code  event-code.+.action
    =/  target=cal  (need (~(get-calendar al alma.state) cal-code))
    ::  must have write access to calendar to delete an event
    ?>  (can-write-cal [owner permissions]:target src.bowl)
    =/  rid=resource  (resource-for-calendar cal-code)
    =/  ts=to-subscriber:ucal-store  [rid %update %event-removed cal-code event-code]
    =/  deleted-event=event  (need (~(get-event al alma.state) cal-code event-code))
    :-
      [[%give %fact ~[/almanac] %ucal-to-subscriber-0 !>(ts)] (make-uninvite-cards deleted-event)]
    state(alma (~(delete-event al alma.state) event-code cal-code))
    ::
      %change-rsvp
    =/  input  +.action
    ::  must have write access to calendar to invite/uninvite anybody
    =/  target=cal  (need (~(get-calendar al alma.state) calendar-code.input))
    ?>  (can-write-cal [owner permissions]:target src.bowl)
    =/  change=rsvp-change:ucal-store
        :^    calendar-code.input
            event-code.input
          who.input
        ?:(invite.input [~ ~] ~)
    =/  [new-event=(unit event) new-alma=almanac]
        (~(update-rsvp al alma.state) change)
    ?~  new-event
      `state
    =/  rid=resource  (resource-for-calendar calendar-code.input)
    =/  ts=to-subscriber:ucal-store  [rid %update %rsvp-changed change]
    =/  invite-card=card
        =/  inv=invitation:ucal-store
            ?.  invite.input
              [%removed [calendar-code event-code]:input]
            [%invited u.new-event &]
        (make-invitation-poke-card who.input inv)
    =/  updates-to-invitees=(list card)
        ::  send an update to every invitee who ISNT the ship whose
        ::  invite changed w/this poke (since we already created a card
        ::  for them above).
        %+  turn
          ~(tap in (~(del in ~(key by invites.data.u.new-event)) who.input))
        |=  guest=@p
        ^-  card
        (make-invitation-poke-card guest [%invited u.new-event |])
    :-  [[%give %fact ~[/almanac] %ucal-to-subscriber-0 !>(ts)] invite-card updates-to-invitees]
    state(alma new-alma)
    ::
      %import-from-ics
    ::  only the ship (or a moon) ucal-store is running on can import calendars
    ?>  (team:title our.bowl src.bowl)
    =/  input  +.action
    =/  =vcalendar:ucal-components
    ?:  ?=([%path *] input)
      (calendar-from-file:ucal-parser path.input)
    ?:  ?=([%data *] input)
      (calendar-from-cord:ucal-parser data.input)
    !!
    =/  [cc=term rng=_~(. og 0)]  (make-uuid ~(. og `@`eny.bowl) 8)
    =/  [cal=calendar events=(list event)]
        (vcal-to-ucal vcalendar cc our.bowl now.bowl rng)
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
    :-  ~[[%give %fact ~[/almanac] %ucal-to-subscriber-0 !>(ts)]]
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
::
++  poke-ucal-invitation
  |=  inv=invitation:ucal-store
  ^-  (quip card _state)
  ::  no cards produced here
  :-  ~
  ?:  ?=([%invited *] inv)
    =/  key=[calendar-code event-code]  [calendar-code event-code]:data.event.inv
    ::  we always want to overwrite our old notion of the event
    =/  deleted-from=almanac
        (~(delete-event al invited-to.state) +.key -.key)
    ::  src.bowl is the ship that sent us this poke, which means it's
    ::  the one we want to send our response to. make sure that we're
    ::  not getting invitations from multiple ships for the same event.
    ?>  =(src.bowl (~(gut by outgoing-rsvps.state) key src.bowl))
    %=  state
      invited-to  (~(add-event al deleted-from) event.inv)
      outgoing-rsvps  (~(put by outgoing-rsvps.state) key src.bowl)
    ==
  ?:  ?=([%removed *] inv)
    =/  key=[calendar-code event-code]  +.inv
    =/  hosting-ship=@p  (~(got by outgoing-rsvps.state) key)
    ?>  =(hosting-ship src.bowl)
    %=  state
      invited-to  (~(delete-event al invited-to.state) +.key -.key)
      outgoing-rsvps  (~(del by outgoing-rsvps.state) key)
    ==
  !!
::
++  poke-ucal-invitation-reply
  |=  reply=invitation-reply:ucal-store
  ^-  (quip card _state)
  =/  =event  (need (~(get-event al alma.state) [calendar-code event-code]:reply))
  ::  must be getting this from a ship who is invited to the event
  ?>  |(=(src.bowl organizer.about.data.event) (~(has by invites.data.event) src.bowl))
  =/  hash=@  (get-event-invite-hash event)
  ?.  =(hash hash.reply)
    `state
  =/  change=rsvp-change:ucal-store
      :^    calendar-code.reply
          event-code.reply
        src.bowl
      ``status.reply
  =/  [upd=(unit ^event) new-alma=almanac]  (~(update-rsvp al alma.state) change)
  =/  rid=resource  (resource-for-calendar calendar-code.reply)
  =/  ts=to-subscriber:ucal-store  [rid %update %rsvp-changed change]
  ::  send out an update to subscribers as well as to all invited ships
  ::  (including the respondee) so they know the current status of other
  ::  invites.
  :-  [[%give %fact ~[/almanac] %ucal-to-subscriber-0 !>(ts)] (make-invite-cards (need upd) |)]
  state(alma new-alma)
::
++  poke-http-response
  =<
  |=  [eyre-id=@ta req=inbound-request:eyre]
  ^-  (quip card _state)
  :_  state
  %+  make-http-response
    eyre-id
  ?+    method.request.req
    =/  data=octs
      (as-octs:mimes:html '<h1>405 Method Not Allowed</h1>')
    =/  content-length=@t
      (crip ((d-co:co 1) p.data))
    =/  =response-header:http
      :-  405
      :~  ['Content-Length' content-length]
          ['Content-Type' 'text/html']
          ['Allow' 'GET']
      ==
    [response-header data]
  ::
      %'GET'
    =/  pax=path  (stab url.request.req)
    ~&  [%path-is pax]
    ?>  =((lent pax) 3)
    =/  =ship  (slav %p (snag 1 pax))
    =/  target-almanac=(unit almanac)
    ?:  =(ship our.bowl)
      `alma.state
    (~(get by external.state) `entity`ship)
    ?~  target-almanac
      calendar-not-found-404
    =/  cc=calendar-code  (snag 2 pax)
    =/  c  (~(get-calendar al u.target-almanac) cc)
    ?~  c
      calendar-not-found-404
    =/  evs  (~(get-events-bycal al u.target-almanac) cc)
    ?~  evs
      calendar-not-found-404
    ::  Since anyone can send us this unauthenticated GET request we
    ::  only support requests for public calendars.
    ::  TODO conceptually should we only allow the exposure of public
    ::  calendars on our ship? I could see arguments for both but tbh
    ::  since we can support both AND the other calendars were public
    ::  anyway I don't think it really matters.
    ?.  (is-public permissions.u.c)
      calendar-not-found-404
    =/  data=octs
    %-  as-octs:mimes:html
    %-  of-wain:format
    (turn (convert-calendar-and-events:conv u.c u.evs) crip)
    =/  content-length=@t
      (crip ((d-co:co 1) p.data))
    =/  =response-header:http
      :-  200
      :~  ['Content-Length' content-length]
          ['Content-Type' 'text/calendar']
      ==
    [response-header data]
  ==
  |%
  ::  +make-http-response: helper for producing the eyre cards needed
  ::  for manual http handling.
  ::
  ++  make-http-response
    |=  [eyre-id=@ta =response-header:http data=octs]
    ^-  (list card)
    :~
      [%give %fact [/http-response/[eyre-id]]~ %http-response-header !>(response-header)]
      [%give %fact [/http-response/[eyre-id]]~ %http-response-data !>(`data)]
      [%give %kick [/http-response/[eyre-id]]~ ~]
    ==
  ::  +calendar-not-found-404: standard 404 we want to send
  ::
  ++  calendar-not-found-404
    ^-  [response-header:http octs]
    =/  data=octs
      (as-octs:mimes:html '<h1>404 Calendar not found</h1>')
    =/  content-length=@t
      (crip ((d-co:co 1) p.data))
    =/  =response-header:http
      :-  404
      :~  ['Content-Length' content-length]
          ['Content-Type' 'text/html']
      ==
    [response-header data]
  --
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
      [%calendar-and-events *]
    =/  c  (get-calendar t.path almanac)
    ?~  c
      ~
    =/  evs  (get-events-bycal t.path almanac)
    ?~  evs
      ~
    ``ucal-calendar-and-events+!>([u.c u.evs])
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
::
++  make-invitation-poke-card
  |=  [to=@p inv=invitation:ucal-store]
  ^-  card
  =/  wir=wire
      ?:  ?=([%invited *] inv)
        (weld /inviting/(scot %p to) [calendar-code event-code ~]:data.event.inv)
      ?:  ?=([%removed *] inv)
        (weld /uninviting/(scot %p to) [calendar-code event-code ~]:inv)
      !!
  :*  %pass
      wir
      %agent
      [our.bowl %ucal-store]
      %poke
      %ucal-invitation
      !>(`invitation:ucal-store`inv)
  ==
::
++  make-invite-cards
  |=  [=event rsvp-required=flag]
  ^-  (list card)
  =/  inv=invitation:ucal-store  [%invited event rsvp-required]
  =/  ships=(set @p)  ~(key by invites.data.event)
  ::  the organizer should never be getting a card here - but they
  ::  shouldn't be in the invites map to begin with.
  ?<  (~(has in ships) organizer.about.data.event)
  %~  tap
    in
  ^-  (set card)
  %-  ~(run in ships)
  |=  who=@p
  ^-  card
  (make-invitation-poke-card who inv)
::
++  make-uninvite-cards
  |=  =event
  ^-  (list card)
  =/  inv=invitation:ucal-store  [%removed [calendar-code event-code]:data.event]
  =/  ships=(set @p)  ~(key by invites.data.event)
  ::  the organizer should never be getting a card here - but they
  ::  shouldn't be in the invites map to begin with.
  ?<  (~(has in ships) organizer.about.data.event)
  %~  tap
    in
  ^-  (set card)
  %-  ~(run in ships)
  |=  who=@p
  ^-  card
  (make-invitation-poke-card who inv)
--
