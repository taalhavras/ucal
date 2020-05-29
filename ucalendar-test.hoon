/+  ucalendar-parser
=,  ucalendar-parser
:-  %say
|=  [[now=@da * [p=@p * *]] ~ ~]
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
=/  lines=wall
    (read-file /(scot %p p)/home/(scot %da now)/txt/ics/txt)
(parse-calendar lines)
