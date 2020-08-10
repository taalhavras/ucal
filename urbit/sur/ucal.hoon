/+  ucal-components
|%
:: TODO: enumerated list of all possible timezones
+$  timezone  @t
+$  title     @t
+$  event-code  @tas
+$  calendar-code  @tas
::
+$  calendar
  $:  owner=@p
      =calendar-code                                    :: internal name, unique
      =title                                            :: external name
      =timezone
      date-created=@da
      last-modified=@da
  ==
::
+$  event
  $:
    =event-code                                       :: unique id
    =about                                            :: metadata
    =detail                                           :: title, desc, location
    when=moment
    era=(unit era)
    =invites
    =rsvp                                             :: organizer rsvp
  ==
:: Information about the event, e.g. metadata.
::
+$  about
  $:  organizer=@p
      date-created=@da
      =event-type
  ==
::  events are 'projected' if they're based on an era and have not yet been
::  reified. a concrete event is a reified event event in an era, or an event
::  that is not part of an era.
::
+$  event-type  $?(%projected %concrete)
::  Details about the event itself.
::
+$  detail
  $:  =title
      desc=(unit @t)
      loc=(unit location)
  ==
::  A location has a written address that may or may not resolve to an actual
::  set of geographic coordinates.
::
+$  coordinate  $:(lat=@rd lon=@rd)
::
+$  location
  $:
    address=@t
    geo=(unit coordinate)
  ==
::
::  Those that are invited to the event.
::
+$  rsvp  $?(%yes %no %maybe)
::
+$  invite
  $:  who=@p
      note=@t
      =event-code
      optional=?
      ::  if ~, then the invited party hasn't responded
      rsvp=(unit rsvp)
      sent-at=@da
  ==
::
+$  invites  (map @p invite)
--
