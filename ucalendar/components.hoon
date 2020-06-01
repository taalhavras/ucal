|%
:: TODO tagged union here for component
++  component  $%([%vevent v=vevent])
+$  event-class  $?
    %public
    %private
    %confidential
    ==
::  we EITHER have the end time of the event OR a duration
::  the duration is always positive
+$  event-ending  $%
    [%dtend d=date]
    [%duration t=tarp]
    ==
+$  event-status  ?(%tentative %confirmed %cancelled)
+$  latlon  $:(lat=dn lon=dn)
::  ical period datatype
+$  period  $%
    [%explicit begin=date end=date]
    [%start begin=date duration=tarp]
    ==
+$  rdate  $%
    [%date d=date]
    [%period p=period]
    ==
+$  vevent
    $:
    ::  Required Fields
    ::  date event was created
    dtstamp=date
    ::  unique id
    uid=cord
    ::  start of event
    dtstart=date
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
    exdate=(list date)
    ==
--
