::  /-  *resource
::
|%
::  $calendars: a mapping from calendar-ids to calendars
::
::  +$  calendars  (map resource calendar)
::  $calendar: a container for events
::  FIXME these stub definitions might need to be updated
::  to fit with "resource"
+$  uid  @tas
+$  code  uid
::
::    TODO:
+$  calendar
  $:  name=@t
      created=@da
      events=(list event)                :: reverse chronological / newest first
      ::  eras=(list era)                    :: reverse chronological / newest first
  ==
+$  timezone  @t              :: TODO: enumerated list of all possible timezones
+$  event-type  $?(%projected %concrete)      :: potential as result of era, or real
+$  source      $?(%invite %era)
+$  ref         [ship=@p =source =code]             :: a reference to another entity
::  A location has a written address that may or may not resolve to an actual
::  set of geographic coordinates.
::
+$  coordinate  $:(lat=@rd lon=@rd)
::
+$  location
  $:  address=@t
      geo=(unit coordinate)
  ==
::
::  Details about the event.
::
+$  detail
  $:  title=@t
      desc=(unit @t)
      loc=(unit location)
  ==
::
::  When the event will occur. Can be all day, relative to a start date, or have
::  an explicit start and end.
::
+$  moment
  $%  [%days day=(list @da)]                           :: all day
      [%block anchor=@da span=@dr]                     :: anchor & relative end
      [%period start=@da end=@da]                      :: definite start and end
  ==
::
::  Era
::  An era is our equivalent of a recurrence rule. Start and end define when the
::  recurrence starts and when it ends, if at all.
::
::  TODO
+$  rule
  $:
    type=rule-type
    interval=$~(1 @)
    ::  TODO model the actual recurrences
    $%  [%daily]
        ::  FIXME problem is these must all be timezone aware, so events
        ::  must track I guess.
        [%weekly (set weekday)]
        ::  gcal offers nth day of the month or nth weekday of the month here
        [%monthly]
        ::  yearly on the specified date - unclear how to handle leap cases but
        ::  maybe we just add ~y1 or something.
        [%yearly on=@da]
    ==
  ==
::
+$  rule-type
  $%  [%until last=@da]
      [%instances num=@ud]
      ::  don't think this one needs anything?
      [%infinite]
  ==
::
+$  weekday
  $?
    %mon
    %tue
    %wed
    %thu
    %fri
    %sat
    %sun
  ==
::
+$  when
  $%  [%moment =moment]
      [%era start=@da end=(unit @da) =rule]
  ==
::
+$  event
  $:  =uid                                              :: unique id
      organizer=@p                                      :: ship that owns
      =detail                                           :: title, desc, location
      =when
      =invites
      =rsvp                                             :: organizer rsvp
      date-created=@da
  ==
::
:: Information about the event, e.g. metadata.
::
+$  about
  $:  organizer=@p
      date-created=@da
      =type
      source=(unit ref)                                 :: link to source: either era, or invite
  ==
::
::  Those that are invited to the event.
::
+$  rsvp  $?(%yes %no %maybe)
::
+$  invite
  $:  who=@p
      note=@t
      event=code
      optional=?
      rsvp=(unit rsvp)
      sent-at=@da
  ==
::
+$  invites  (map @p invite)
::
::  Calendar
::
--
