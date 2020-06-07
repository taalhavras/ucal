|%
::
+$  action
  $%  $:  %new-calendar
          name=@tas
          title=@t
      ==
  ::
      $:  %new-event
          who=@p
          cal=@tas
          title=@t
          start=@da
          end=dur
          description=@t
      ==
  ==
::
+$  calendar
  $:  owner=@p
      name=@tas                                         :: internal name, unique
      title=@t                                          :: external name
      events=(list event)
      date-created=@da
      last-modified=@da
  ==
::
+$  event
  $:  organizer=@p
      name=@tas                                         :: internal name, unique
      title=@t                                          :: external name
      description=@t
      start=@da
      duration=dur
      date-created=@da
      last-modified=@da
  ==
::
+$  dur
  $%  [%end @da]
      [%span @dr]
  ==
--
