/-  ucal
/+  ucal-util, conv=ucal-ics-converter
|_  ev=event:ucal
++  grow
  |%
  ++  noun  ev
  ++  json  (event-to-json:ucal-util ev)
  ++  ics
    %-  of-wain:format
    (turn (convert-event:conv ev) crip)
  --
::
++  grab
  |%
  ++  noun  event:ucal
  --
::
++  grad  %noun
--
