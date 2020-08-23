::  stores all timezones mapped by name
::
/+  ucal-timezone, utc=ucal-timezones-utc
|%
::  keys should be lowercase
::
++  all-timezones
  ^-  (map tape tz:ucal-timezone)
  %-  malt
  ^-  (list [tape tz:ucal-timezone])
  :~
    ["utc" utc]
  ==
::
++  get-tz
  |=  tzid=tape
  ^-  tz:ucal-timezone
  (~(gut by all-timezones) (cass tzid) utc)
--
