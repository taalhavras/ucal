/-  *iana-components
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
--
