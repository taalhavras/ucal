|%
::
+$  calendar
  $:  owner=@p
      code=@tas                                         :: internal name, unique
      title=@t                                          :: external name
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
+$  dur                                               :: TODO: Is this worth it?
  $%  [%end @da]
      [%span @dr]
  ==
+$  action
  $%  $:  %create-calendar
          code=@tas
          title=@t
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
      $:  %query-events
          calendars=(set @tas)
          period=(unit [from=@da to=@da])
      ==
  ==
--
