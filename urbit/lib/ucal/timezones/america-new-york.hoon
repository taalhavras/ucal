/+  hora
=>
|%
::  daylight savings starts on the second sunday in march
::
++  get-daylight-start
  |=  y=@ud
  ^-  @da
  =/  d=date  [[& y] 3 *tarp]
  (nth-weekday:hora %sun d %second)
::  standard time starts on the first sunday in november
::
++  get-standard-start
  |=  y=@ud
  ^-  @da
  =/  d=date  [[& y] 11 *tarp]
  (nth-weekday:hora %sun d %first)
::
++  is-daylight
  |=  a=@da
  ^-  ?
  =/  y=@ud  y:(yore a)
  &((gte a (get-daylight-start y)) (lth a (get-standard-start y)))
::
++  get-offset
  |=  a=@da
  ^-  @dr
  ?:  (is-daylight a)
    ~h4
  ~h5
--
|%
++  to-utc
  |=  a=@da
  ^-  @da
  (sub a (get-offset a))
++  from-utc
  |=  a=@da
  ^-  @da
  (add a (get-offset a))
--
