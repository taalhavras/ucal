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
--
