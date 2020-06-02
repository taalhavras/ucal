|%
:: TODO tagged union here for component
++  component  $%([%vevent v=vevent])
+$  ical-time  $%
    [%date d=date]
    [%date-time d=date utc=?]
    ==
+$  ical-date  $>(%date ical-time)
+$  ical-datetime  $>(%date-time ical-time)
::  either have end date or duration
+$  event-ending  $%
    [%dtend d=ical-time]
    [%duration t=tarp]
    ==
+$  event-class  $?
    %public
    %private
    %confidential
    ==
+$  event-status  ?(%tentative %confirmed %cancelled)
+$  latlon  $:(lat=dn lon=dn)
::  ical period datatype, always date-times
+$  period  $%
    [%explicit begin=ical-datetime end=ical-datetime]
    [%start begin=ical-datetime duration=tarp]
    ==
+$  rdate  $%
    [%time d=ical-time]
    [%period p=period]
    ==
::  TODO based on how this is being done now I don't think the defaults
::  produced by $~ are needed anymore - do they add clarity? prevent misuse?
::  or are they just superfluous?  I don't see the harm in keeping them.
+$  rrule  $:
    ::  freq is the only required part
    freq=rrule-freq
    ::  ending date for event
    until=(unit ical-time)
    ::  number of occurrences
    count=(unit @)
    ::  interval times freq gives the intervals at which
    ::  the recurrence occurs. The default is 1
    interval=$~(1 @)
    ::  These lists contain intervals that (depending on freq) either
    ::  increase or constrain the size of the recurrence set. See
    ::  rfc 5545 page 44 for more info
    bysecond=(list @)
    byminute=(list @)
    byhour=(list @)
    byweekday=(list rrule-weekdaynum)
    bymonthday=(list rrule-monthdaynum)
    byyearday=(list rrule-yeardaynum)
    byweek=(list rrule-weeknum)
    bymonth=(list rrule-monthnum)
    bysetpos=(list rrule-setpos)
    ::  start of workweek, default is monday
    weekstart=$~(%mo rrule-day)
    ==
+$  rrule-freq  $?
    %secondly
    %minutely
    %hourly
    %daily
    %weekly
    %monthly
    %yearly
    ==
::  days of the week, sunday to saturday
+$  rrule-day  $?
    %su
    %mo
    %tu
    %we
    %th
    %fr
    %sa
    ==
+$  rrule-weekdaynum  $:
    day=rrule-day
    weeknum=(unit rrule-weeknum)
    ==
::  TODO so these next types could all be represented using one, maybe with a tag?
+$  rrule-monthdaynum  $:
    sign=?
    monthday=@
    ==
+$  rrule-yeardaynum  $:
    sign=?
    yearday=@
    ==
+$  rrule-weeknum  $:
    sign=?
    ordweek=@
    ==
+$  rrule-monthnum  $:
    sign=?
    month=@
    ==
::  setpos spec'd to be same as yeardaynum
+$  rrule-setpos  $:
    sign=?
    setpos=@
    ==
+$  vevent
    $:
    ::  Required Fields
    ::  date event was created (always a date-time)
    dtstamp=ical-datetime
    ::  unique id
    uid=cord
    ::  start of event
    dtstart=ical-time
    ::  end of our event
    end=event-ending
    ::
    ::  Optional Fields, all either unit or lists?
    ::
    ::  event organizer
    ::  TODO So according to the RFC this has to be a mailto email address
    ::  but for our purposes we probably want something different when parsing
    organizer=(unit tape)
    ::  categories the event falls under
    categories=wall :: (list tape)
    ::  Access classifications for calendar event (basically permissions)
    ::  TODO Since these aren't really enforced (more like notes on what the
    ::  event creator wanted) should we even have this?
    classification=(unit event-class)
    ::  comments from event creator on the event
    comment=wall :: (list tape)
    ::  description of the event
    description=(unit tape)
    ::  summary of event
    summary=(unit tape)
    ::  lat/lon where the event is occurring
    geo=(unit latlon)
    ::  a location of the event
    location=(unit tape)
    ::  event status
    ::  TODO again is this necessary?
    status=(unit event-status)
    ::  nested components - for vevents only valarms can be nested
    ::  TODO there's probably a way to make this _just_ valarms.
    ::  Look into the mold runes relating to type restrictions
    ::  TODO this line seems problematic - produces really odd
    ::  ford errors - are mutually recursive types not allowed or
    ::  something? is my ship just being weird?
    ::  alarms=(list component)

    ::  recurrence stuff will probably be the most tricky
    :: RRULE
    :: RDATE
    rdate=(list rdate)
    :: EXDATE
    exdate=(list ical-time)
    ==
--
