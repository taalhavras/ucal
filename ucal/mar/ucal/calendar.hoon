/-  ucal
/+  ucal-util, conv=ucal-ics-converter
|_  cal=calendar:ucal
++  grow
  |%
  ++  noun  cal
  ++  json  (calendar-to-json:ucal-util cal)
  ++  ics  (convert-calendar-and-events:conv cal ~)
  --
::
++  grab
  |%
  ++  noun  calendar:ucal
  --
::
++  grad  %noun
--
