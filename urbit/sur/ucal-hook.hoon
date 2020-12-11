/-  *ucal-store
|%
::  +public-calendars: reserved term used in the resource that represents calendar metadata
++  public-calendars  %public-calendars
::
::  $metadata: metadata for a given calendar
::
+$  metadata
  $:
    owner=@p
    title=cord
    =calendar-code
  ==
::  $action: poke for the pull-hook to retrieve
::
+$  action
  $%  [%query-cals who=@p]
  ==
::  $update: sent by the push-hook in response to an action
::
+$  update
  $%  [%metadata source=@p items=(list metadata)]
  ==
--
