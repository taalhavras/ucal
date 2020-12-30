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
  =(d.delta 0)
::
++  in-range
  |=  [[from=@da to=(unit @da)] target=@da]
  ^-  flag
  ?.  (gte target from)
    |
  ?~  to
    &
  (lte target u.to)
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

--
