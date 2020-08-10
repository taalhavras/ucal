/-  ucal
|%
::
:: period of time, properly ordered
::
++  period
  |=  [a=@da b=@da]
  ^-  [@da @da]
  ?:  (lth b a)
    [b a]
  [a b]
::
::  period of time from absolute start and dur, properly ordered
::
++  period-from-dur
  |=  [start=@da =dur:ucal]
  ^-  [@da @da]
  =/  end=@da
      ?-    -.dur
        %end  +.dur
        %span  (add +.dur start)
      ==
  (period start end)
--
