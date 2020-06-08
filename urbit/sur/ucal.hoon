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
      duration=dur
      description=(unit @t)
      date-created=@da
      last-modified=@da
  ==
::
+$  dur
  $%  [%end @da]
      [%span @dr]
  ==
+$  action
  $%  $:  %new-calendar
          code=@tas
          title=@t
      ==
      ::
      $:  %delete-calendar
          code=@tas
      ==
      ::
      $:  %new-event
          calendar=@tas
          title=@t
          start=@da
          end=dur
          description=(unit @t)
      ==
  ==
--
