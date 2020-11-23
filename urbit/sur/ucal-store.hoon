/-  *hora, *ucal, ucal-timezone, *ucal-almanac, *resource
|%
::
::
+$  calendar-patch
  $:
    owner=(unit @p)
    =calendar-code
    title=(unit @t)
  ==
::
+$  event-patch
  $:
    =calendar-code
    =event-code
    title=(unit title)
    ::  fields of detail
    desc=(unit (unit @t))
    loc=(unit (unit location))
    description=(unit (unit @t))
    ::
    when=(unit moment)
    era=(unit (unit era))
    tzid=(unit tape)
  ==
::
+$  rsvp-change
  $:
    =calendar-code
    =event-code
    who=@p
    :: if ~, then uninvite the @p
    status=(unit rsvp)
  ==
::
+$  action
  $%  $:  %create-calendar
          title=@t
      ==
      ::
      $:  %update-calendar
          patch=calendar-patch
      ==
      ::
      $:  %delete-calendar
          =calendar-code
      ==
      ::
      $:  %create-event
          =calendar-code
          organizer=@p
          =detail
          when=moment
          era=(unit era)
          =invites
          tzid=tape
      ==
      ::
      $:  %update-event
          patch=event-patch
      ==
      ::
      :: - delete event
      $:  %delete-event
          =calendar-code
          =event-code
      ==
      :: - cancel event?
      :: - change rsvp
      $:  %change-rsvp
          =rsvp-change
      ==
      :: - import calendar from file
      $:  %import-from-ics
          =path
      ==
  ==
::
::  $to-subscriber: sent to subscribers - union of initial
::  payload and periodic updates
::
+$  to-subscriber
  $:
    =resource
    $%
      [%initial =calendar events=(list event)]
      [%update =update]
    ==
  ==
::
::  $update: updates sent to subscribers
::
+$  update
  $%
    [%calendar-changed patch=calendar-patch]
    [%calendar-removed =calendar-code]
    [%event-added =event]
    [%event-changed patch=event-patch]
    [%event-removed =calendar-code =event-code]
    [%rsvp-changed =rsvp-change]
  ==
--
