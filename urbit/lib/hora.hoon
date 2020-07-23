/-  *hora
|%
++  weekdays-by-idx
  ^-  (map @ud weekday)
  %-  ~(gas by *(map @ud weekday))
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
::  all materialized events starting within the range.
::
++  events-in-range
  |=  [=event start=@da end=@da]
  ^-  (list event)
  ?>  (lte start end)
  !!
::  +get-weekday: gets weekday that a given date falls on.
::  implementation of sakamoto's method
::
++  get-weekday
  =<
  |=  da=@da
  ^-  weekday
  =/  =date  (yore da)
  =/  y=@ud  y.date
  =/  m=@ud  m.date
  =/  d=@ud  d.t.date
  ::  produces 0 for sunday, 1 for monday, etc.
  =/  idx=@ud
      =/  y=@ud
          ?:  (lth m 3)
            (dec y)
          y
      %+  mod
        %+  sub
          ;:  add
            y
            (div y 4)
            (div y 400)
            (~(got by month-table) m)
            d
          ==
        (div y 100)
      7
  (~(got by weekdays-by-idx) idx)
  |%
  ++  month-table
    ^-  (map @ud @ud)
    %-  ~(gas by *(map @ud @ud))
    :~
      [1 0]
      [2 3]
      [3 2]
      [4 5]
      [5 0]
      [6 3]
      [7 5]
      [8 1]
      [9 4]
      [10 6]
      [11 2]
      [12 4]
    ==
  --
--
