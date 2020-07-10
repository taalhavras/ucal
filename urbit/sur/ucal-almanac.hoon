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
  ++  add-event
    |=  =event
    ^-  almanac
    =/  =events  (~(get ja events.alma) calendar-code.event)
    alma(events (~(put by events.alma) calendar-code.event (insort events event)))
  ::
  ++  add-calendar
    |=  =calendar
    ^-  almanac
    alma(cals (~(put by cals.alma) calendar-code.calendar calendar))
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
      events  (~(put by events) c-code new-events)
    ==
  ::
  ++  update-calendar
    |=  [patch=calendar-patch now=@da]
    ^-  almanac
    =/  cal=calendar  (~(got by cals.alma) calendar-code.patch)
    =/  new=calendar
        %=  cal
          owner  (fall owner.patch owner.cal)
          title  (fall title.patch title.cal)
          timezone (fall timezone.patch timezone.cal)
          last-modified now
        ==
    %=  alma
      cals  (~(put by cals.alma) calendar-code.patch new)
    ==
  ::
  ++  update-event
    |=  [patch=event-patch now=@da]
    ^-  almanac
    =/  [to-update=(unit event) rest=events]
        (remove-event event-code.patch (~(get ja events.alma)))
    ?~  to-update
      alma
    =/  cur=event  u.to-update
    =/  new-event=event
        %=  cur
          owner  (fall owner.patch owner.cur)
          title  (fall title.patch title.cur)
          start  (fall start.patch start.cur)
          end  (fall end.patch end.cur)
          description  (fall description.patch description.cur)
          last-modified  now
        ==
    %=  alma
      events  (~(put by events.alma) calendar.patch (insort rest new-event))
    ==
  ::  +insort: adds a given event to a list, maintaining
  ::  reverse-chronological order by start time.
  ::
  ++  insort
    |=  =events =event
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
  ==
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
        %+  skid
          |=(e=event =(code event-code.e))
        events
    =/  n=@  (lent match)
    ?:  =(n 0)
      [~ rest]
    ?>  =(n 1)
    [`(snag 0 match) rest]
  ::
  ++  get-calendar
    |=  code=calendar-code
    ^-  (unit calendar)
    (~(get by cals.alma) code)
  ::
  ++  get-event
    |=  [=calendar-code =event-code]
    ^-  (unit event)
    =/  =events  (~(get ja events.alma) calendar-code)
    =/  match=^events
        %+  skim
          |=(e=event =(code event-code.e))
        events
    ?~  match
      ~
    ?>  =((lent match) 1)
    `(snag 0 match)
==
