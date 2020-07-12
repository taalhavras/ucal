/-  *ucal
|%
::  $almanac: organizes multiple calendars and events
::
+$  almanac
  $:
    cals=(map calendar-code calendar)
    events=(jar calendar-code event)
  ==
::  +al: door for almanac manipulation
::
++  al
  |_  alma=almanac
  ::
  ++  add-calendar
    |=  =calendar
    ^-  almanac
    alma(cals (~(put by cals.alma) calendar-code.calendar calendar))
  ::
  ++  add-event
    |=  =event
    ^-  almanac
    =/  =events  (~(get ja events.alma) calendar-code.event)
    alma(events (~(put by events.alma) calendar-code.event (insort events event)))
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
    =/  old-events=events  (~(get ja events.alma) c-code)
    =/  [removed=(unit event) new-events=events]
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
    =/  new-tz=timezone
        ?~  timezone.patch
          timezone.u.cal
        ?~  u.timezone.patch
          'utc'
        u.u.timezone.patch
    =/  new=calendar
        %=  u.cal
          owner  (fall owner.patch owner.u.cal)
          title  (fall title.patch title.u.cal)
          timezone  new-tz
          last-modified  now
        ==
    :-
      `new
    %=  alma
      cals  (~(put by cals.alma) calendar-code.patch new)
    ==
  ::
  ++  update-event
    |=  [patch=event-patch now=@da]
    ^-  [(unit event) almanac]
    =/  [to-update=(unit event) rest=events]
        %+  remove-event
          event-code.patch
        (~(get ja events.alma) calendar-code.patch)
    ?~  to-update
      [~ alma]
    =/  cur=event  u.to-update
    =/  p=[@da @da]
        =/  new-start  (fall start.patch start.cur)
        ?~  end.patch
          (period new-start end.cur)
        (period-from-dur new-start u.end.patch)
    =/  new-event=event
        %=  cur
          owner  (fall owner.patch owner.cur)
          title  (fall title.patch title.cur)
          start  -.p
          end  +.p
          description  (fall description.patch description.cur)
          last-modified  now
        ==
    :-
      `new-event
    %=  alma
      events  (~(put by events.alma) calendar-code.patch (insort rest new-event))
    ==
  ::
  ++  update-rsvp
    |=  rsvp=rsvp-change
    ^-  [(unit event) almanac]
    =/  old=(unit events)  (get-events-bycal calendar-code.rsvp)
    ?~  old
      [~ alma]
    =/  [new-event=(unit event) new=events]
        %+  reel  u.old
        |=  [cur=event acc=[(unit event) events]]
        ^-  [(unit event) events]
        ?.  =(event-code.cur event-code.rsvp)
          [-.acc cur +.acc]
        ::  found target, update rsvps
        =/  new-event=event
            ?~  status.rsvp
              cur(rsvps (~(del by rsvps.cur) who.rsvp))
            cur(rsvps (~(put by rsvps.cur) who.rsvp u.status.rsvp))
        [`new-event new-event +.acc]
      ?~  new-event
        [~ alma]
      :-  new-event
      alma(events (~(put by events.alma) calendar-code.rsvp new))
  ::  +insort: adds a given event to a list, maintaining
  ::  reverse-chronological order by start time.
  ::
  ++  insort
    |=  [=events =event]
    ^-  ^events
    =|  acc=^events
    |-
    ?~  events
      ::  event is older than all previous ones, add to end
      (flop [event acc])
    ?.  (gte start.event start.i.events)
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
    |=  [code=event-code =events]
    ^-  [(unit event) ^events]
    ::  %-  head
    ::  %+  reel  events
    ::  |=  [cur=event acc=[l=events present=flag]]
    ::      ?.  present.acc
    ::        [[cur l] |]
    ::      ?:  =(event-code.cur code)
    ::        [l |]
    ::      [[cur l] &]
    =/  [match=^events rest=^events]
        %+  skid  events
        |=(e=event =(code event-code.e))
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
    ^-  events
    %-  zing
    (turn ~(tap by events.alma) tail)
  ::
  ++  get-events-bycal
    |=  code=calendar-code
    ::  TODO do we want this to produce a unit list or a list?
    ::  use ja for list and by for unit list
    ^-  (unit events)
    (~(get by events.alma) code)
  ::
  ++  get-event
    |=  [=calendar-code =event-code]
    ^-  (unit event)
    =/  =events  (~(get ja events.alma) calendar-code)
    =/  match=^events
        %+  skim  events
        |=(e=event =(event-code event-code.e))
    ?~  match
      ~
    ?>  =((lent match) 1)
    `i.match
  --
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
  |=  [start=@da =dur]
  ^-  [@da @da]
  =/  end=@da
      ?-    -.dur
        %end  +.dur
        %span  (add +.dur start)
      ==
  (period start end)
--
