/-  ucal
/+  ucal-util, conv=ucal-ics-converter
|_  evs=(list event:ucal)
++  grow
  |%
  ++  noun  evs
  ++  json  [%a (turn evs event-to-json:ucal-util)]
  ++  ics
    %-  of-wain:format
    (turn (convert-events:conv evs) crip)
  --
::
++  grab
  |%
  ++  noun  (list event:ucal)
  --
::
++  grad  %noun
--
