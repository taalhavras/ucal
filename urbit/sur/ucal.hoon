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
          =calendar-code
          title=(unit @t)
          timezone=(unit (unit timezone))
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
          =calendar-code
          =event-code
          title=(unit @t)
          start=(unit @da)
          end=(unit dur)
          description=(unit (unit @t))
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
      :: - modify event
      :: - modify calendar
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
