/-  *hora
|%
++  weekdays-by-idx
  ^-  (map @ud weekday)
  %-  (~(gas by *(map @ud weekday)))
  :~
    [0 %sun]
    [1 %mon]
    [2 %tue]
    [3 %wed]
    [4 %thu]
    [5 %fri]
    [6 %sat]
  ==
::  +events-in-range: given a recurring event and a range, produce a list of
::  all materialized events within the range.
::
++  events-in-range
  |=  [=event start=@da end=@da]
  ^-  (list event)
  ?> (lte start end)
  !!
::  +get-weekday: gets weekday that a given date falls on
::  formula taken from
::
++  get-weekday
  |=  da=@da
  ^-  weekday
  =/  =date  (yore da)
  =/  y=@ud  y.date
  =/  m=@ud  m.date
  =/  d=@ud  d.t.date
  ::  produces 0 for sunday, 1 for monday, etc.
  =/  idx=@ud
      =/  d=@ud  (add m d)
      =/  y=@ud
          ?:  (lth d 3)
            (dec y)
          (sub y 2)
       %_  mod
         7
       %_  sub
         (div y 100)
       ;:  add
         (div (mul 23 m) 9)
         d
         4
         (div y 4)
         (div y 400)
       ==
  (~(got by weekdays-by-idx) idx)
--
