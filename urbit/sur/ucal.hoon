|%
:: TODO: enumerated list of all possible timezones
+$  timezone  @t
::
+$  calendar
  $:  owner=@p
      code=@tas                                         :: internal name, unique
      title=@t                                          :: external name
      =timezone
      date-created=@da
      last-modified=@da
  ==
::
+$  event
  $:  owner=@p
      calendar=@tas
      code=@tas                                         :: internal name, unique
                                                        :: TODO are codes unique across calendars?
      title=@t                                          :: external name
      start=@da
      end=@da
      description=(unit @t)
      date-created=@da
      last-modified=@da
      rsvps=(map @p rsvp-status)
  ==
::
+$  calendars  (list calendar)
+$  events  (list event) ::
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
          code=@tas
          title=@t
          timezone=(unit timezone)                      :: optional, otherwise utc
      ==
      ::
      $:  %delete-calendar
          code=@tas
      ==
      ::
      $:  %create-event
          calendar=@tas
          title=@t
          code=@tas
          start=@da
          end=dur
          description=(unit @t)
      ==
      ::
      :: TODO:
      :: TODO not sure if we want calendar-code on delete-event
      :: and change-rsvp - just the event code could be enough if
      :: they're globally unique. even in that case optionally
      :: specifying the calendar could be good too.
      :: - delete event
      $:  %delete-event
          calendar-code=@tas
          event-code=@tas
      ==
      :: - cancel event?
      :: - change rsvp
      $:  %change-rsvp
          calendar-code=@tas
          event-code=@tas
          who=@p
          status=rsvp-status
      ==
      :: - modify event
      :: - modify calendar
  ==
--
