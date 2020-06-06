|%
:: TODO tagged union here for component
++  component  $%([%vevent v=vevent])
+$  ical-time  $%
    [%date d=date]
    [%date-time d=date utc=?]
    ==
+$  ical-date  $>(%date ical-time)
+$  ical-datetime  $>(%date-time ical-time)
::  a signed duration, %.y for positive
+$  ical-duration  $:(sign=? t=tarp)
::  either have end date or duration
+$  event-ending  $%
    [%dtend d=ical-time]
    [%duration t=tarp] ::  always a positive duration
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
    [%start begin=ical-datetime duration=tarp] ::  always a positive duration
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
::  event transparencies, opaque is default
+$  vevent-transparency  $?
    %transparent
    %opaque
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
    alarms=(list valarm)

    ::  recurrence rule
    rrule=(unit rrule)
    ::  list of dates to include in the recurrence set
    rdate=(list rdate)
    ::  list of dates to exclude from the recurrence set
    exdate=(list ical-time)
    ::  creation and update times - these must be UTC date-times
    ::  TODO since they must be UTC, can we just store the date?
    created=(unit ical-datetime)
    last-modified=(unit ical-datetime)
    ::  revision sequence number, defaults to 0
    sequence=@
    ::  event transparency, how it appears to others who
    ::  look at your schedule.
    transparency=vevent-transparency
    ::  event priority, 0-9. 0 is undefined, 1 is highest prio, 9 lowest
    priority=@
    ::  url associated w/event
    url=(unit tape)
    ==
+$  valarm-action  ?(%audio %display %email)
::  a trigger can be related to the start or end of an event.
::  default is start
+$  valarm-related  ?(%end %start)
::  either have a related trigger or an absolute one
+$  valarm-trigger  $%
    [%rel related=valarm-related duration=ical-duration]
    [%abs dt=ical-datetime]
    ==
::  duration is the interval to repeat on, repeat is the count.
::  this duration must be positive
+$  valarm-duration-repeat  $:(duration=tarp repeat=@)
+$  valarm-audio  $:
    ::  Required fields
    trigger=valarm-trigger
    ::  Optional fields
    duration-repeat=(unit valarm-duration-repeat)
    attach=(unit tape)
    ==
+$  valarm-display  $:
    ::  Required fields
    trigger=valarm-trigger
    description=tape ::  text to display
    ::  Optional fields
    duration-repeat=(unit valarm-duration-repeat)
    ==
+$  valarm-email  $:
    ::  Required fields
    trigger=valarm-trigger
    description=tape ::  email body
    summary=tape ::  email subject
    attendees=(lest tape) ::  email address - must be at least one
    :: Optional fields
    attach=(list tape)
    ==
+$  valarm  $%
    [%audio audio=valarm-audio]
    [%display display=valarm-display]
    [%email email=valarm-email]
    ==
--
