/+  ucal-components
|%
:: TODO: enumerated list of all possible timezones
+$  timezone  @t
+$  event-code  @tas
+$  calendar-code  @tas
::
+$  calendar
  $:  owner=@p
      =calendar-code                                    :: internal name, unique
      title=@t                                          :: external name
      =timezone
      date-created=@da
      last-modified=@da
  ==
::
+$  calendar-patch
  $:  owner=(unit @p)
      =calendar-code
      title=(unit @t)
      timezone=(unit (unit timezone))
  ==
::
+$  event
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
+$  event-patch
  $:  owner=(unit @p)
      calendar=calendar-code
      =event-code
      title=(unit @t)
      start=(unit @da)
      end=(unit dur)
      description=(unit (unit @t))
  ==
::
+$  rsvp-change
  $:  =calendar-code
      =event-code
      who=@p
      status=rsvp-status
  ==
::
+$  calendars  (list calendar)
+$  events  (list event)
:: TODO:
:: - rsvp
+$  rsvp-status  $?(%yes %no %maybe %unanswered)
::
+$  dur                                               :: TODO: Is this worth it?
  $%  [%end @da]
      [%span @dr]
  ==
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
          =calendar-code
          =event-code
          who=@p
          status=rsvp-status
      ==
      :: - import calendar from file
      $:  %import-from-ics
          =path
      ==
  ==
::  $initial: sent to subscribers on initial subscription
::
+$  initial
  $%
    [%calendars =calendars]
    [%events-bycal =events]
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
