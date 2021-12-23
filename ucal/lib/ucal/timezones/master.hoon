::  stores all timezones mapped by name
::
/-  ucal-timezone
/+  utc=ucal-timezones-utc, ny=ucal-timezones-america-new-york
|%
::  keys should be lowercase
::
++  all-timezones
  ^-  (map tape tz:ucal-timezone)
  %-  malt
  ^-  (list [tape tz:ucal-timezone])
  :~
    ["utc" utc]
    ["america/new_york" ny]
  ==
::
++  get-tz
  |=  tzid=tape
  ^-  tz:ucal-timezone
  (~(gut by all-timezones) (cass tzid) utc)
--
