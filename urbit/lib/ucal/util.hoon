/-  *ucal, *hora, components=ucal-components
/+  *hora, utc=ucal-timezones-utc
|%
::  +events-overlapping-in-range: given an event and a range, produces
::  a unit event (representing whether the input event overlaps with
::  the target range) and a list of projected events (if the event is
::  recurring, these are the generated instances that also fall in range).
::  IMPORTANT: THE INPUT TIMES ARE ASSUMED TO BE IN UTC.
::  TODO could change above by also taking in a timezone and applying adjustment?
++  events-overlapping-in-range
  =<
  |=  [e=event start=@da end=@da]
  ^-  [(unit event) (list projected-event)]
  ?>  (lte start end)
  ::  adjust by timezone
  =/  [start=@da end=@da]  [(from-utc.tz.data.e start) (from-utc.tz.data.e end)]
  =/  [event-start=@da event-end=@da]  (moment-to-range when.data.e)
  ?~  era.e
    :_  ~
    ?:  (ranges-overlap start end event-start event-end)
      `e
    ~
  ::  TODO this is implementation dependent on overlapping-in-range
  ::  returning the original moment first if it does in fact overlap.
  ::  maybe there's a better way to handle this?
  ::  ah actually, if it overlaps it'll be in front but if it starts
  ::  in the range it'll be at the very end of l. I mean I guess knowing
  ::  that, we can't really do much except check both cases...
  ::  FIXME we could also just do the most general "filter" approach for now
  ::  and revisit if performance here is crushingly bad or something...
  =/  l=(list moment)  (overlapping-in-range start end when.data.e u.era.e)
  =/  f  (bake (curr project [data.e u.era.e]) moment)
  =/  [original=(list moment) proj=(list moment)]
      (skid l |=(m=moment =(m when.data.e)))
  :_  (turn proj f)
  ?~  original
    ~
  ?>  =((lent original) 1)
  `e
  |%
  ++  project
    |=  [m=moment ed=event-data =era]
    ^-  projected-event
    [ed(when m) era]
  --
::  utilities for converting event/calendar codes to/from cords
++  cc-to-cord
  |=  =calendar-code
  ^-  @t
  (crip <calendar-code>)
::
++  ec-to-cord
  |=  =event-code
  ^-  @t
  (crip <event-code>)
::
++  cord-to-cc
  |=  =cord
  ^-  calendar-code
  %-  from-digits
  (rash cord (plus sid:ab))
::
++  cord-to-ec
  |=  =cord
  ^-  event-code
  %-  from-digits
  (rash cord (plus sid:ab))
::  +from-digits:  converts a list of digits to a single atom
::
++  from-digits
  |=  l=(list @)
  ^-  @ud
  (roll l |=([cur=@ud acc=@ud] (add (mul 10 acc) cur)))
::  +vcal-to-ucal: converts a vcalendar to our data representation
::
++  vcal-to-ucal
  |=  [=vcalendar:components =calendar-code owner=@p now=@da]
  ^-  [calendar (list event)]
  =/  cal=calendar
    %:  calendar
      owner
      calendar-code
      (crip prodid.vcalendar)
      now
      now
    ==
  :-  cal
  %-  head
  %+  reel
    events.vcalendar
  |=  [cur=vevent:components events=(list event) code=event-code]
  ^-  [(list event) event-code]
  =/  res=(unit event)  (vevent-to-event cur code calendar-code owner now)
  ?~  res
    [events code]
  [[u.res events] +(code)]
::  +vevent-to-event: attempts to parse event from vevent
::
++  vevent-to-event
  |=  [v=vevent:components =event-code =calendar-code owner=@p now=@da]
  ^-  (unit event)
  =/  res=(unit (unit era))  (parse-era rrule.v rdate.v exdate.v)
  ?~  res
    ~
  %-  some
  %:  event
    %:  event-data
      event-code
      calendar-code
      %:  about
        owner
        (fall created.v now)
        (fall last-modified.v now)
      ==
      %:  detail
        (fall (bind summary.v crip) '')
        (bind description.v crip)
        (parse-location location.v geo.v)
      ==
      (parse-moment ical-time.dtstart.v end.v)
      `invites`~  :: TODO parse invites? what does this look like?
      `rsvp`%yes  :: TODO parse rsvp? unclear what this should be
      ::  TODO parse the actual timezone
      utc
    ==
    u.res
  ==
::
++  parse-location
  |=  [loc=(unit tape) geo=(unit latlon:components)]
  ^-  (unit location)
  ::  TODO how do we want to handle situations where only geo is specified?
  ::  our current definition of location doesn't handle it - update?
  ?~  loc
    ~
  =/  address=@t  (crip u.loc)
  ?~  geo
    `[address ~]
  `[address `[(ryld lat.u.geo) (ryld lon.u.geo)]]
::
++  parse-moment
  |=  [start=ical-time:components end=event-ending:components]
  ^-  moment
  ?:  ?=([%date *] start)
    ?:  ?=([%dtend *] end)
      ?:  ?=([%date *] end.end)
        [%days d.start +((div (sub d.end.end d.start) ~h24))]
      [%period d.start d.end.end]
    [%block d.start duration.end]
  ?:  ?=([%dtend *] end)
    ?:  ?=([%date *] end.end)
      [%period d.start d.end.end]
    [%period d.start d.end.end]
  [%block d.start duration.end]
::  +parse-era: given parsed components of rrule, produce an era.
::  if the rrule cannot be parsed into our era, produce ~. If there
::  is no rrule, produce [~ ~]. if there is a valid rrule, produce
::  the era.
::
++  parse-era
  |=  [rrule=(unit rrule:components) rdate=(list rdate:components) exdate=(list ical-time:components)]
  ^-  (unit (unit era))
  ?~  rrule
    [~ ~]
  !!
--
