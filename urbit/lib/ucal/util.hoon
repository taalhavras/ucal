/-  *ucal, *hora, *ucal-components
/+  *hora
|%
::  +events-overlapping-in-range: given an event and a range, produces
::  a unit event (representing whether the input event overlaps with
::  the target range) and a list of projected events (if the event is
::  recurring, these are the generated instances that also fall in range)
++  events-overlapping-in-range
  =<
  |=  [e=event start=@da end=@da]
  ^-  [(unit event) (list projected-event)]
  ?>  (lte start end)
  =/  [event-start=@da event-end=@da]  (moment-to-range when.data.e)
  ?~  era.e
    :_  ~
    ?:  (ranges-overlap start end event-start event-end)
      `e
    ~
  ::  TODO this is implementation dependent on overlapping-in-range
  ::  returning the original moment first if it does in fact overlap.
  ::  maybe there's a better way to handle this?
  ::  ah actually, if it overlaps it'll be in front but if it starts
  ::  in the range it'll be at the very end of l. I mean I guess knowing
  ::  that, we can't really do much except check both cases...
  ::  FIXME we could also just do the most general "filter" approach for now
  ::  and revisit if performance here is crushingly bad or something...
  =/  l=(list moment)  (overlapping-in-range start end when.data.e u.era.e)
  =/  f  (bake (curr project [data.e u.era.e]) moment)
  =/  [original=(list moment) proj=(list moment)]
      (skid l |=(m=moment =(m when.data.e)))
  :_  (turn proj f)
  ?~  original
    ~
  ?>  =((lent original) 1)
  `e
  |%
  ++  project
    |=  [m=moment ed=event-data =era]
    ^-  projected-event
    [ed(when m) era]
  --
::  +vcal-to-ucal: converts a vcalendar to our data representation
++  vcal-to-ucal
  |=  vcal=vcalendar
  ^-  [calendar (list event)]
  !!
--
