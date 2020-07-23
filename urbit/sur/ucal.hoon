/+  ucal-components
|%
:: TODO: enumerated list of all possible timezones
+$  timezone  @t
+$  title     @t
+$  event-code  @tas
+$  calendar-code  @tas
::
:: These are for uniquely representing entities.
::
+$  code    @tas                                  :: a unique code within a ship
::  +$  entity  $?(%calendar %event %era)           :: different types of resource
::
+$  calendar  calendar-1
::
+$  calendar-1
  $:  owner=@p
      =calendar-code                                    :: internal name, unique
      title=@t                                          :: external name
      =timezone
      date-created=@da
      last-modified=@da
  ==
::
+$  calendar-2
  $:  owner=@p
      =code
      =title
      date-created=@da
      events=(list event)                :: reverse chronological / newest first
      eras=(list era)                    :: reverse chronological / newest first
  ==
::
:: An era is our equivalent of a recurrence rule. Start and end define when the
:: recurrence starts and when it ends, if at all.
::
+$  era
  $:  start=@da
      end=(unit @da)
      =code
      :: =rules
  ==
::
+$  event  event-1
::
+$  event-1
  $:  owner=@p
      calendar=calendar-code
      =event-code                                       :: internal name, unique
      title=@t                                          :: external name
      start=@da
      end=@da                                           :: converted from dur
      description=(unit @t)
      date-created=@da
      last-modified=@da
      rsvps=(map @p rsvp-status)
  ==
::
:: Information about the event, e.g. metadata.
::
+$  about
  $:  organizer=@p
      date-created=@da
      =type
      source=(unit ref)                                 :: where this event came from: either an era, or an invite
  ==
::  events are 'projected' if they're based on an era and have not yet been
::  reified. a concrete event is a reified event event in an era, or an event
::  that is not part of an era.
+$  type  $?(%projected %concrete)
::
+$  source  $?(%invite %era)
+$  ref     [ship=@p =source =code]    :: a reference to another entity
::
::  When the event will occur. Can be all day, relative to a start date, or have
::  an explicit start and end.
::
+$  moment
  $%  [%day day=@da]                                    :: all day
      [%block start=@da span=@dr]                       :: start & relative end
      [%period start=@da end=@da]                       :: definite start and end
  ==
::
::  Details about the event itself.
::
+$  detail
  $:  =title
      desc=(unit @t)
      :: TODO: location in GCal is either an actual location (lat/lon) or an arbitrary string
      ::  loc=(unit [lat=@rd lon=@rd])
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
+$  event-2
  $:  =code
      =about
      when=moment
      =detail
      =invites
      =rsvp                                             :: organizer rsvp
  ==
::
+$  calendars  (list calendar)
+$  events     (list event)
::
+$  rsvp-status  $?(%yes %no %maybe %unanswered)
::
+$  dur                                               :: TODO: Is this worth it?
  $%  [%end @da]
      [%span @dr]
  ==
--
