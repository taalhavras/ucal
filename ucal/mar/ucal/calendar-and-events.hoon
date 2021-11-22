/-  ucal
/+  conv=ucal-ics-converter, util=ucal-util, parz=ucal-parser
|_  [cal=calendar:ucal evs=(list event:ucal)]
++  grow  :: convert to
  |%
  ++  noun  [cal evs]
  ++  ics
    %-  of-wain:format
    (turn (convert-calendar-and-events:conv cal evs) crip)
  --
::
++  grab  :: convert from
  |%
  ++  noun  [calendar:ucal (list event:ucal)]
  --
::
++  grad  %noun
--
