/-  *iana-components
/+  lhora=hora
|%
::  +add-delta: add a delta to a given @da
::
++  add-delta
  |=  [time=@da =delta]
  ^-  @da
  %.  [time d.delta]
  ?:  sign.delta
    add
  sub
::  +sub-delta: subtract a delta from a given @da
::
++  sub-delta
  |=  [time=@da =delta]
  ^-  @da
  (add-delta time delta(sign !sign.delta))
::  +is-zero: check if delta is zero (sign irrelevant)
::
++  is-zero
  |=  =delta
  ^-  flag
  =(d.delta ~s0)
::  +in-range: bounds checking (with potentially infinite upper bound)
::
++  in-range
  |*  [[from=@ to=(unit @)] target=@]
  ^-  flag
  ?.  (gte target from)
    |
  ?~  to
    &
  (lte target u.to)
::
++  is-standard
  |=  re=rule-entry
  ^-  flag
  (is-zero save.re)
::
++  is-daylight-saving
  |=  re=rule-entry
  ^-  flag
  !(is-zero save.re)
::  +spice: door for seasoned time operations
::
++  spice
  |_  stdoff=delta
  ++  lth
    =<
    |=  [a=seasoned-time b=seasoned-time]
    ^-  flag
    ?:  =(a.flavor b.flavor)
      (lth when.a when.b)
    =/  at=@da  (seasoned-to-standard a stdoff)
    =/  bt=@da  (seasoned-to-standard b stdoff)
    (lth at bt)
    |%
    ::  +seasoned-to-standard: takes a seasoned-time that's stdoff away from
    ::  utc and produces an @da representing the corresponding local standard
    ::  time.
    ::
    ++  seasoned-to-standard
      |=  [st=seasoned-time stdoff=delta]
      ^-  @da
      ?-  flavor.st
          %standard
        when.st
      ::
          %utc
        (add-delta when.st stdoff)
      ::
          %wallclock
        ::  For now I'm just treating this like local standard time
        ::  - I don't think it impacts any use cases.
        when.st
      ==
    --
  ::
  ++  gth
    |=  [a=seasoned-time b=seasoned-time]
    ^-  flag
    (lth b a)
  ::
  ++  lte
    |=  [a=seasoned-time b=seasoned-time]
    ^-  flag
    !(lth b a)
  ::
  ++  gte
    |=  [a=seasoned-time b=seasoned-time]
    ^-  flag
    !(lth a b)
  --
::  +build-seasoned-time: construct a seasoned time from the requisite
::  components. there are two cases were we want to use this:
::    1. RULE Records: We can combine the FROM/TO, IN, ON, and AT
::       columns into a seasoned-time.
::    2. ZONE Records: The UNTIL column can be parsed into
::       a seasoned-time. However, since the only required field is
::       years, we make the other components optional. Note that it
::       doesn't seem possible to supply i.e. hours without specifying
::       a day.
::
++  build-seasoned-time
  |=  [cur-year=@ud month-idx=(unit @ud) on=(unit rule-on) offset=(unit @dr) flavor=(unit time-flavor)]
  ^-  seasoned-time
  =/  d=date  [[& cur-year] 1 [1 0 0 0 ~]]
  :_  (fall flavor %wallclock)
  ?~  month-idx
    (year d)
  =/  d=date  d(m u.month-idx)
  ?~  on
    (year d)
  =/  d=date
      ?@  u.on
        d(d.t u.on)
      =/  day=weekday:hora  -.u.on
      ?:  ?=([%instance *] +.u.on)
        (yore (nth-weekday:lhora day d +>:u.on))
      ?.  ?=([%on *] +.u.on)
        !!
      ::  find first instance of day >= +>:u.on
      =/  d=date  d(d.t +>:u.on)
      =/  bound-day=weekday:hora  (get-weekday-from-date:lhora d)
      d(d.t (add d.t.d (weekdays-until:lhora day bound-day)))
  (add (year d) (fall offset ~s0))
::  +find-rule-entry: takes an input local standard time that's stdoff
::  away from utc and find the rule-entry that applies to it.
::
++  find-rule-entry
  =<
  |=  [when=@da stdoff=delta tzr=tz-rule]
  ^-  rule-entry
  =/  d=date  (yore when)
  =/  standard=rule-entry  (find-in-range standard.tzr y.d)
  =/  saving=rule-entry  (find-in-range saving.tzr y.d)
  ::  build both seasoned-times,
  =/  st-standard=seasoned-time
      (build-seasoned-time y.d `in.standard `on.standard `offset.at.standard `flavor.at.standard)
  =/  st-saving=seasoned-time
      (build-seasoned-time y.d `in.saving `on.saving `offset.at.saving `flavor.at.saving)
  ::  now order them
  ?:  (~(lth spice stdoff) st-standard st-saving)
    (pick-entry a standard b saving when)
  (pick-entry b saving a standard when)
  |%
  ++  find-in-range
    |=  [l=(list rule-entry) y=@ud]
    ^-  rule-entry
    ?~  l
      !!
    ?:  (in-range [from.i.l to.i.l] y)
      i.l
    $(l t.l)
  --
  ::
  ++  pick-entry
    |=  [a=@da ar=rule-entry b=@da br=rule-entry x=@da]
    ^-  rule-entry
    ::  caller should pass a < b
    ::  a < b <= x -> b
    ::  a <= x < b -> a
    ::  x <= a < b -> b
    ?:  &((gte x a) (lth x b))
      ar
    br
::
++  get-zone-entry
  |=  [zon=zone when=seasoned-time]
  ^-  zone-entry
  |-
  ?~  entries.zon
    !!
  ?.  (~(gte spice stdoff.zon) from.i.entries.zon)
    $(entries.zon t.entries.zon)
  ?~  to.i.entries.zon
    i.entries.zon
  ?:  (~(lt spice stdoff.zon) u.to.i.entries.zon)
    i.entries.zon
  $(entries.zon t.entries.zon)
::
::
++  utc-conversion-helper
  |=  [zon=zone st=seasoned-time func=$-([@da delta] @da)]
  ^-  @da
  ::  get relevant zone entry
  =/  ze=zone-entry  (get-zone-entry zon st)
  =/  pre-rules=@da  (func when.st stdoff.ze)
  ?:  ?=([%nothing *] rules.ze)
    pre-rules
  ?:  ?=([%delta *] rules.ze)
    (func pre-rules +:rules.ze)
  ?:  ?=([%rule *])
    ::  apply offset based on rules - how to get the timezones by name?
    ::  .^ with a store? pass a map?
    =/  tzr=tz-rule  !!
    =/  entry=tz-rule-entry  (find-rule-entry when.st stdoff.ze tzr)
    (func pre-rules save.entry)
  !!
::  +from-utc: convert an @da in utc to the corresponding wallclock time
::  in the given timezone.
::
++  from-utc
  |=  [zon=zone utc=@da]
  ^-  @da
  (utc-conversion-helper zon [utc %utc] add-delta)
::  +to-utc: convert an @da in wallclock time in the specified timezone
::  to the corresponding utc time.
::
++  to-utc
  |=  [zon=zone wallclock=@da]
  ^-  @da
  (utc-conversion-helper zon [wallclock %wallclock] sub-delta)
--
