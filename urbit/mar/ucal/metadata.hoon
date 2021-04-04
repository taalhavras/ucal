/-  ucal-hook, ucal
/+  ucal-util
|_  lst=(list metadata:ucal-hook)
++  grow
  |%
  ++  noun  lst
  ++  json
    |^  ^-  json
    [%ar (turn lst metadata-to-json)]
    ++  metadata-to-json
      |=  m=metadata:ucal-hook
      ^-  json
      =,  format
      %-  pairs:enjs
      :~  [%owner (ship:enjs owner.m)]
          [%title (tape:enjs (trip title.m)]
          [%calendar-code (tape:enjs (trip calendar-code.m))]
      ==
    --
  --
::
++  grab
  |%
  ++  noun  (list metadata:ucal-hook)
  --
::
++  grad  %noun
--
