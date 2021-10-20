/-  ucal, ucal-store
|%
::  +public-calendars: reserved term used in the resource that represents calendar metadata
++  public-calendars  `term`%public-calendars
::
::  $metadata: metadata for a given calendar
::
+$  metadata
  $:  owner=@p
      title=cord
      =calendar-code:ucal-store
  ==
::  $action: poke for the pull-hook
::
+$  action
  $%  [%query-cals who=@p]
      ::  used to respond to invites (pokes a foreign ucal-store)
      [%invitation-response =calendar-code:ucal =event-code:ucal status=rsvp:ucal-store]
  ==
::  $update: sent by the push-hook in response to a %query-cals poke
::
+$  update
  $%  [%metadata source=@p items=(list metadata)]
  ==
--
