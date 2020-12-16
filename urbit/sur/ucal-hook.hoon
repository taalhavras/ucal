/-  ucal-store
|%
::  +public-calendars: reserved term used in the resource that represents calendar metadata
++  public-calendars  `term`%public-calendars
::
::  $metadata: metadata for a given calendar
::
+$  metadata
  $:
    owner=@p
    title=cord
    =calendar-code:ucal-store
  ==
::  $action: poke for the pull-hook
::
+$  action
  $%  [%query-cals who=@p]
      ::  forwards poke to target's store (can be local)
      [%proxy-poke target=@p store-action=action:ucal-store]
  ==
::  $update: sent by the push-hook in response to an action
::
+$  update
  $%  [%metadata source=@p items=(list metadata)]
  ==
--
