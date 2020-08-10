/-  *hora, *ucal
|%
::
::
+$  calendar-patch
  $:
    owner=(unit @p)
    =calendar-code
    title=(unit @t)
    timezone=(unit (unit timezone))
  ==
::
+$  event-patch
  $:
    =calendar-code
    =event-code
    title=(unit title)
    desc=(unit (unit @t))
    loc=(unit (unit location))
    when=(unit moment)
    description=(unit (unit @t))
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
          =calendar-code
          title=@t
          timezone=(unit timezone)                      :: optional, otherwise utc
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
          title=@t
          =event-code
          start=@da
          end=dur
          description=(unit @t)
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
::  $initial: sent to subscribers on initial subscription
::
+$  initial
  $%
    [%calendars calendars=(list calendar)]
    [%events-bycal events=(list event)]
  ==
::  $update: updates sent to subscribers
::
+$  update
  $%
    [%calendar-added =calendar]
    [%calendar-changed =calendar]
    [%calendar-removed =calendar-code]
    [%event-added =event]
    [%event-changed =event]
    [%event-removed =event-code]
  ==
--
