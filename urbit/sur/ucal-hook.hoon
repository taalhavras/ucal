/-  *ucal-store
|%
::  $metadata: metadata for a given calendar
::
+$  metadata
  $:
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
