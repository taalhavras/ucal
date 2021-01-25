/-  ucal
/+  ucal-util
|_  [evs=(list event:ucal) proj=(list projected-event:ucal)]
++  grow
  |%
  ++  noun  [evs proj]
  ++  json
    %-  pairs:enjs:format
    :~  ['real' [%a (turn evs event-to-json:ucal-util)]]
        ['projected' [%a (turn proj projected-event-to-json:ucal-util)]]
    ==
  --
::
++  grab
  |%
  ++  noun  [(list event:ucal) (list projected-event:ucal)]
  --
::
++  grad  %noun
--
