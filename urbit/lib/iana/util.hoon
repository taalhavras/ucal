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
::  +rule-entry-applies: takes an input local standard time that's delta
::  away from utc and determines if a given rule-entry applies to it.
::
++  rule-entry-applies
  |=  [when=@da offset=delta re=rule-entry]
  ^-  flag
  =/  d=date  (yore when)
  ?.  (in-range [from.re to.re] y.d)
    |
  ::  now construct a seasoned time from our entry and calculate
  ::  the wallclock @da this rule came into effect.
  =/  st=seasoned-time
      (build-seasoned-time y.d `in.re `on.re `offset.at.re `flavor.at.re)
  %+  gte
    when
  ^-  @da
  ?-  flavor.st
      %standard
    when.st
  ::
      %utc
    (sub-delta when.st offset)
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
++  find-rule-entry
  =<
  |=  [when=@da tzr=tz-rule]
  ^-  rule-entry
  !!
  |%
  --
--
