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
    |=  [a=seasoned-time b=seasoned-time]
    ^-  flag
    ?:  =(a.flavor b.flavor)
      (lth when.a when.b)
    !!
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
::  away from utc and determines if a given rule-entry applies to it.
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
  =/  a=@da  (seasoned-to-standard st-standard stdoff)
  =/  b=@da  (seasoned-to-standard st-saving stdoff)
  ?:  (lth a b)
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
      ::  a bit trickier - the input is in local standard time,
      ::  and we've determined that this rule is in play year-wise.
      ::  TODO what does it mean for this time to be given in wallclock
      ::  time? does it mean that the save associated with this has been
      ::  applied? for non daylight saving time rule entries this is the
      ::  same as local standard time, but if save is NOT zero how do we
      ::  interpret this?
      ::
      ::  For now I'm just treating this like local standard time because
      ::  it doesn't really make sense for a rule to be considered in
      ::  effect when we're still determining if it applies to a given
      ::  local time. It'd be worth asking someone who knows more about
      ::  this.
      when.st
    ==
::
++  get-zone-entry
  |=  [zon=zone when=seasoned-time]
  ^-  zone-entry
  !!
::  +from-utc: convert an @da in utc to the corresponding wallclock time
::  in the given timezone.
::
++  from-utc
  |=  [zon=zone utc=@da]
  ^-  @da
  !!
::  +to-utc: convert an @da in wallclock time in the specified timezone
::  to the corresponding utc time.
::
++  to-utc
  |=  [zon=zone wallclock=@da]
  ^-  @da
  !!
--
