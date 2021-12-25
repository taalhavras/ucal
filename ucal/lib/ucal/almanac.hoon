/-  *ucal-almanac, *ucal-store
/+  hora, ucal-util
|%
::  +al: door for almanac manipulation
::
++  al
  |_  alma=almanac
  ::
  ++  add-calendar
    |=  =calendar
    ^-  almanac
    %=  alma
      cals  (~(put by cals.alma) calendar-code.calendar calendar)
      events  (~(put by events.alma) calendar-code.calendar ~)
    ==
  ::
  ++  add-event
    |=  =event
    ^-  almanac
    =/  events=(list ^event)  (~(get ja events.alma) calendar-code.data.event)
    %=  alma
      events  (~(put by events.alma) calendar-code.data.event (insort events event))
    ==
  ::
  ++  add-events
    |=  events=(list event)
    ^-  almanac
    %-  tail :: only care about state produced in spin, not list
    %^  spin  events
      alma
    |=  [e=event alma=almanac]
    ^-  [event almanac]
    [e (~(add-event al alma) e)]
  ::
  ++  delete-calendar
    |=  code=calendar-code
    ^-  almanac
    %=  alma
      cals  (~(del by cals.alma) code)
      events  (~(del by events.alma) code)
    ==
  ::
  ++  delete-event
    |=  [e-code=event-code c-code=calendar-code]
    ^-  almanac
    =/  old-events=(list event)  (~(get ja events.alma) c-code)
    =/  [removed=(unit event) new-events=(list event)]
        (remove-event e-code old-events)
    ?~  removed
      alma
    %=  alma
      events  (~(put by events.alma) c-code new-events)
    ==
  ::
  ++  update-calendar
    |=  [patch=calendar-patch now=@da]
    ^-  [(unit calendar) almanac]
    =/  cal=(unit calendar)  (~(get by cals.alma) calendar-code.patch)
    ?~  cal
      [~ alma]
    =/  new=calendar
        %=  u.cal
          title  (fall title.patch title.u.cal)
          last-modified  now
        ==
    :-
      `new
    %=  alma
      cals  (~(put by cals.alma) calendar-code.patch new)
    ==
  ::
  ++  change-permissions
    |=  [cc=calendar-code new-perms=calendar-permissions]
    ^-  [(unit calendar) almanac]
    =/  cal=(unit calendar)  (~(get by cals.alma) cc)
    :-  cal
    ?~  cal
      alma
    %=  alma
      cals  (~(put by cals.alma) cc u.cal(permissions new-perms))
    ==
  ::
  ++  update-event
    |=  [patch=event-patch now=@da]
    ^-  [(unit event) almanac]
    =/  [to-update=(unit event) rest=(list event)]
        %+  remove-event
          event-code.patch
        (~(get ja events.alma) calendar-code.patch)
    ?~  to-update
      [~ alma]
    =/  cur=event  u.to-update
    =/  new-detail=detail
      %=  detail.data.cur
        title  (fall title.patch title.detail.data.cur)
        desc  (fall desc.patch desc.detail.data.cur)
        loc  (fall loc.patch loc.detail.data.cur)
      ==
    =/  new-event=event
        %=  cur
          detail.data  new-detail
          about.data  about.data.cur(last-modified now)
          when.data  (fall when.patch when.data.cur)
          tzid.data  (fall tzid.patch tzid.data.cur)
          era  (fall era.patch era.cur)
        ==
    ::  reset invites for all guests if the era or moment has changed
    =/  reset-invites=flag
        ?|  !=(era.cur era.new-event)
            !=(when.data.cur when.data.new-event)
        ==
    =/  new-event=event
        ?.  reset-invites
          new-event
        new-event(invites.data (clear-invites:ucal-util invites.data.new-event))
    :-  `new-event
    %=  alma
      events  (~(put by events.alma) calendar-code.patch (insort rest new-event))
    ==
  ::  +update-rsvp: used to handle ships responding to invites
  ::
  ++  update-rsvp
    |=  rsvp=rsvp-change
    ^-  [(unit event) almanac]
    =/  old=(unit (list event))  (get-events-bycal calendar-code.rsvp)
    ?~  old
      [~ alma]
    =/  [new-event=(unit event) new=(list event)]
        %+  reel  u.old
        |=  [cur=event acc=[(unit event) (list event)]]
        ^-  [(unit event) (list event)]
        ?.  =(event-code.data.cur event-code.rsvp)
          [-.acc cur +.acc]
        ::  found target, update invites
        =/  new-event=event
            ::  first check if the change is for the host
            ?:  =(who.rsvp organizer.about.data.cur)
              ::  cannot uninvite organizer and organizer should always
              ::  have an rsvp status.
              cur(rsvp.data (need (need status.rsvp)))
            =/  old-status=(unit (unit ^rsvp))  (~(get by invites.data.cur) who.rsvp)
            ?~  old-status
              ::  in this case the ship wasn't previously invited. the
              ::  change must be [~ ~] - an initial invite
              ?>  =(status.rsvp [~ ~])
              cur(invites.data (~(put by invites.data.cur) who.rsvp ~))
            ::  in this case the ship has previously been invited. any
            ::  invitation change is fine (including a reset to
            ::  "unanswered" even if they haven't responded)
            ?~  status.rsvp
              ::  uninviting the @p
              cur(invites.data (~(del by invites.data.cur) who.rsvp))
            ::  overwriting previous invitation status
            cur(invites.data (~(put by invites.data.cur) who.rsvp u.status.rsvp))
        [`new-event new-event +.acc]
      ?~  new-event
        [~ alma]
      :-  new-event
      alma(events (~(put by events.alma) calendar-code.rsvp new))
  ::  +insort: adds a given event to a list, maintaining
  ::  reverse-chronological order by start time.
  ::
  ++  insort
    |=  [events=(list event) =event]
    ^-  (list ^event)
    =|  acc=(list ^event)
    =/  [e-start=@da e-end=@da]  (moment-to-range:hora when.data.event)
    |-
    ?~  events
      ::  event is older than all previous ones, add to end
      (flop [event acc])
    =/  [start=@da end=@da]  (moment-to-range:hora when.data.i.events)
    ?.  (gte e-start start)
      $(events t.events, acc [i.events acc])
    ::  now our order should be (flop acc) then event then events
    (weld (flop acc) [event events])
  ::  +remove-event: remove an event from a list, returns cell of removed
  ::  event (if present) and remainder of list.
  ::
  ::  TODO maybe you can make this not do unecessary comparisons
  ::  with spin or something? but then you'd probably need to produce
  ::  units and that doesn't really help. We don't want that.
  ::  ah, you can do it with roll/reel though. but then you just keep
  ::  checking the flag... yeah this is prob not worth.
  ::
  ++  remove-event
    |=  [code=event-code events=(list event)]
    ^-  [(unit event) (list event)]
    ::  %-  head
    ::  %+  reel  events
    ::  |=  [cur=event acc=[l=events present=flag]]
    ::      ?.  present.acc
    ::        [[cur l] |]
    ::      ?:  =(event-code.cur code)
    ::        [l |]
    ::      [[cur l] &]
    =/  [match=(list event) rest=(list event)]
        %+  skid  events
        |=(e=event =(code event-code.data.e))
    =/  n=@  (lent match)
    ?:  =(n 0)
      [~ rest]
    ?>  =(n 1)
    [`(snag 0 match) rest]
  ::
  ++  get-calendars
    |.
    ^-  (list calendar)
    (turn ~(tap by cals.alma) tail)
  ::
  ++  get-calendar
    |=  code=calendar-code
    ^-  (unit calendar)
    (~(get by cals.alma) code)
  ::
  ++  get-events
    |.
    ^-  (list event)
    %-  zing
    (turn ~(tap by events.alma) tail)
  ::
  ++  get-events-bycal
    |=  code=calendar-code
    ::  TODO do we want this to produce a unit list or a list?
    ::  use ja for list and by for unit list
    ^-  (unit (list event))
    (~(get by events.alma) code)
  ::
  ++  get-event
    |=  [=calendar-code =event-code]
    ^-  (unit event)
    =/  events=(list event)  (~(get ja events.alma) calendar-code)
    =/  match=(list event)
        %+  skim  events
        |=(e=event =(event-code event-code.data.e))
    ?~  match
      ~
    ?>  =((lent match) 1)
    `i.match
  ::
  ++  get-events-inrange
    |=  [code=calendar-code start=@da end=@da]
    ^-  (unit [(list event) (list projected-event)])
    =/  events=(unit (list event))  (~(get by events.alma) code)
    ?~  events
      ~
    %-  some
    %-  tail
    %^  spin  u.events
      `[(list event) (list projected-event)]`[~ ~]
    |=  [cur=event events=(list event) projections=(list projected-event)]
    ^-  [event (list event) (list projected-event)]
    =/  [e=(unit event) p=(list projected-event)]
        (events-overlapping-in-range:ucal-util cur start end)
    :-  cur
    :_  (weld p projections)
    ?~  e
      events
    [u.e events]
  --
--
