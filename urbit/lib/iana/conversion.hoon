/-  *iana-components
/+  *iana-util
=>
|%
++  utc-conversion-helper
  |=  [[us=@p now=@da] zone-name=@ta st=seasoned-time func=$-([@da delta] @da)]
  ^-  @da
  =/  zon=zone
      .^  zone
        %gx
        (scot %p us)
        %timezone-store
        (scot %da now)
        (scot %p us)
        %zones
        zone-name
      ==
  ::  get relevant zone entry
  =/  ze=zone-entry  (get-zone-entry zon st)
  =/  pre-rules=@da  (func when.st stdoff.ze)
  ?:  ?=([%nothing *] rules.ze)
    pre-rules
  ?:  ?=([%delta *] rules.ze)
    (func pre-rules +:rules.ze)
  ?:  ?=([%rule *] rules.ze)
    ::  apply offset based on rules - how to get the timezones by name?
    ::  .^ with a store? pass a map?
    =/  tzr=tz-rule  !!
    =/  entry=rule-entry  (find-rule-entry st stdoff.ze tzr)
    (func pre-rules save.entry)
  !!

--
::  Door for conversions to/from utc that rely on
::
|_  [us=@p now=@da]
::  +from-utc: convert an @da in utc to the corresponding wallclock time
::  in the given timezone.
::
++  from-utc
  |=  [zone-name=@ta utc=@da]
  ^-  @da
  ?:  =(zone-name 'utc')
    utc
  (utc-conversion-helper [us now] zone-name [utc %utc] add-delta)
::  +to-utc: convert an @da in wallclock time in the specified timezone
::  to the corresponding utc time.
::
++  to-utc
  |=  [zone-name=@ta wallclock=@da]
  ^-  @da
  ?:  =(zone-name 'utc')
    wallclock
  (utc-conversion-helper [us now] zone-name [wallclock %wallclock] sub-delta)
--
