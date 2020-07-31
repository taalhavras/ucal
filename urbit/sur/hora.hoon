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
::  When the event will occur. Can be all day, relative to a start date, or have
::  an explicit start and end.
::
+$  moment
  $%  [%days start=@da n=$~(1 @ud)]                    :: all day for n days
                                                       :: n=1 means just for start
      [%block anchor=@da span=@dr]                     :: anchor & relative end
      [%period start=@da end=@da]                      :: definite start and end
  ==
::
::  Era
::  An era is our equivalent of a recurrence rule. Start and end define when the
::  recurrence starts and when it ends, if at all.
::
::  $weekday-instance: instances of a weekday possible in a month
::
+$  weekday-instance  ?(%first %second %third %fourth %last)
::  $monthly: data needed for monthly recurrences.
::  either on a specific date (i.e. 27th) or on the nth weekday of a month
::
+$  monthly
  $%
    [%on]
    [%weekday instance=weekday-instance]
  ==
::
+$  rrule
  ::  TODO for some reason, we needed the default to not be
  ::  [%daily] or [%yearly] for the code to run don't know why...
  $~
    [%weekly ~]
  $%  [%daily]
      ::  FIXME problem is these must all be timezone aware, so events
      ::  must track I guess. actually, maybe we can just assume all
      ::  times are local and do offsets at the top level calendar.
      [%weekly days=(set weekday)]
      ::  gcal offers nth day of the month or nth weekday of the month here
      ::  worth noting that gcal doesn't handle the case where nth day doesn't
      ::  occur in a month (it just skips over the month) - do we replicate?
      ::  perhaps we can offer a third option, one where it skips and one where
      ::  it doesn't?
      ::  FIXME this is probably gonna run into the problem where
      ::  successive applications of this rule move the date earlier.
      ::  i.e. jan 31st -> feb 28th -> mar 28th.
      ::  this problem is skirted in the case where we don't bother with
      ::  months that don't include the current day.
      ::  maybe we should just make include a signed day part of this or something?
      ::  like you can say 23rd day OR 7th day from end...
      [%monthly form=monthly]
      ::  yearly on the specified date - unclear how to handle leap cases but
      ::  maybe we just add ~d365 and then add one more if we're leap year? or
      ::  actually its add one more when we move past a leap day.
      [%yearly]
  ==
::
+$  era-type
  $%  [%until end=@da]
      [%instances num=@ud]
      [%infinite]
  ==
::
+$  era
  $:
    type=era-type
    interval=$~(1 @ud)
    =rrule
  ==
::
+$  event
  $:  =uid                                              :: unique id
      organizer=@p                                      :: ship that owns
      =detail                                           :: title, desc, location
      =moment
      era=(unit era)
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
