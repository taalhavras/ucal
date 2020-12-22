/-  ucal
/+  ucal-util
|_  evs=(list event:ucal)
++  grow
  |%
  ++  noun  evs
  ++  json  [%a (turn evs event-to-json:ucal-util)]
  --
::
++  grab
  |%
  ++  noun  (list event:ucal)
  --
::
++  grad  %noun
--
