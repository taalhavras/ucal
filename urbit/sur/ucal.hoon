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
      title=@t                                          :: external name
      start=@da
      end=@da
      description=(unit @t)
      date-created=@da
      last-modified=@da
  ==
::
:: TODO:
:: - rsvp
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
      :: - delete event
      :: - cancel event?
      :: - change rsvp
      :: - modify event
      :: - modify calendar
  ==
--
