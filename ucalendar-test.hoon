/+  ucalendar-parser
=,  ucalendar-parser
:-  %say
|=  [[now=@da * [p=@p * *]] [pax=path ~] ~]
:-  %noun
=/  dts=tape  "19870321"
=/  durations=wall
    :~
      "P7W"
      "PT5H0M20S"
      "P15DT5H0M20S"
    ==
::  (turn durations parse-duration)
=/  floats=wall
    :~
      "1"
      "-2"
      "3.2"
      "+22.123"
      "-99.9876"
    ==
::  (turn floats parse-float)
=/  unfoldable=wall
    :~
      "these lines\0d"
      "shouldn't be unfolded\0d"
      "but these ones \0d"
      " should be\0d"
      "so shou\0d"
      " ld these \0d"
      "\09three\0d"
    ==
::  (unfold-lines unfoldable)
::  =/  pax=path  /(scot %p p)/home/(scot %da now)/txt/hg/txt
(calendar-from-file pax)
