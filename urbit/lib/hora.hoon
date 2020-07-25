/-  *hora
|%
++  weekdays-by-idx
  ^-  (map @ud weekday)
  %-  ~(gas by *(map @ud weekday))
  :~
    [0 %sun]
    [1 %mon]
    [2 %tue]
    [3 %wed]
    [4 %thu]
    [5 %fri]
    [6 %sat]
  ==
::
++  idx-by-weekday
  ^-  (map weekday @ud)
  %-  ~(gas by *(map weekday @ud))
  %+  turn
    ~(tap by weekdays-by-idx)
  |=([idx=@ud w=weekday] [w idx])
::  +ranges-overlap: checks if [a, b) and [c, d) overlap.
::
++  ranges-overlap
  |*  [a=@ b=@ c=@ d=@]
  ^-  flag
  &((lth a d) (lth b c))
::  +date-in-range: checks if d is in [start, end)
::
++  date-in-range
  |=  [[start=@da end=@da] d=@da]
  ^-  flag
  &((gte d start) (lth d end))
::  +moment-to-range: gets concrete @da bounds for a moment
::
++  moment-to-range
  |=  =moment
  ^-  [@da @da]
  ?:  ?=([%days *] moment.event)
    :-  start.moment.event
    (add (mul ~d1 n.moment.event) start.moment.event)
  ?:  ?=([%block *] moment.event)
    :-  anchor.moment.event
    (add anchor.moment.event span.moment.event)
  ?:  ?=([%period *] moment.event)
    :-  start.moment.event
    end.moment.event
  !!
::  +next-weekday: given the current weekday, produces the next weekday in days
::  that's after it as well as the number of days away it is.
++  next-weekday
  |=  [cur=weekday days=(set weekday)]
  ^-  [weekday @ud]
  ?>  (~(has in days) cur)
  =/  cur-idx=@ud  (~(get by idx-by-weekday) cur)
  =/  [next-weekday=weekday next-idx=@ud]
      |-
      =/  n=@ud  (mod (inc cur-idx) 7)
      =/  w=weekday  (~(get by weekdays-by-idx) n)
      ?:  (~(has in days) w)
        [w n]
      $(cur-idx n)
  :-  next-weekday
  ::  calculate delta, accounting for indices being mod 7
  ::  TODO what to return if they're equal? with lth produces 0,
  ::  with lte produces 7. I think we want 7
  ?:  (lte next-idx cur-idx)
    (sub (add next-idx 7) cur-idx)
  (sub next-idx cur-idx)
::  +advance-moment: given a moment and a recurrence rule, produce the next moment
::
++  advance-moment
  |=  [m=moment interval=@ud =rrule]
  ^-  moment
  ?<  =(interval 0)  :: nonzero interval
  =/  [start=@da end=@da]  (moment-to-range m)
  ::  get new range, then case m to figure out what flavor
  ::  of moment we should produce.
  =/  new-start=@da
      ?:  ?=([%daily] rrule)
        (add start (mul ~d1 interval))
      ?:  ?=([%weekly *] rrule)
        =/  cur=weekday  (get-weekday start)
        =/  [next=weekday d=@ud]  (next-weekday cur days.rrule)
        =/  [cur-idx=@ud next-idx=@ud]
            [(~(get by idx-by-weekdays) cur) (~(get by idx-by-weekdays) next)]
        ::  check to see if we've advanced by a week. if so, we
        ::  also want to account for this shift (using interval)
        ?:  (lte next-idx cur-idx)
          ;:(add start d (mul ~d7 (dec interval)))
        (add start d)
      ?:  ?=([%monthly *] rrule)
        ?-  form.rrule
            %on
          =/  d=date  (yore start)
          =/  day=@ud  d.t.d
          |-
          =/  new-month=@ud  (add m.d interval)
          =/  new-year=@ud
              ?:  (gth new-month 12)
                +(y.d)
              y.d
          =/  new-d=date  d(m new-month, y new-year)
          =/  new-month-days=@ud
              %+  snag
                (dec new-month)
              ?:  (yelp new-year)
                moy:yo
              moh:yo
          ?:  (lte day new-month-days)
            new-d(d.t day)
          $(d new-d)
          ::
            %weekday  !!
        ==
      ?:  ?=([%yearly] rrule)
        ::  this handles leap year cases more cleanly than
        ::  just adding ~d365 times interval.
        =/  d=date  (yore start)
        (year d(y (add y.d interval)))
      !!
  ?:  ?=([%days *] m)
    [%days new-start n.m]
  ?:  ?=([%block *] m)
    [%block new-start span.m]
  ?:  ?=([%period *] m)
    [%period new-start (add new-start (sub end.m start.m))]
  !!
::  +events-in-range: given a recurring event and a range, produce a list of
::  all materialized events starting OVERLAPPING WITH the range [start, end)
::
++  events-in-range
  =<
  |=  [=event start=@da end=@da]
  ^-  (list event)
  ?>  (lte start end)
  =/  [event-start=@da event-end=@da]
      (moment-to-range moment.event)
  ::  early bailout, event starts after range
  ?:  (lte end event-start)
    ~
  =/  acc=(list event)
      ?:  (ranges-overlap start end event-start event-end)
        ~[event]
      ~
  ::  need an era? or just produce acc?
  ?~  era.event
    acc
  ::  now we case the era-type to see if we are in bounds
  =/  a  ~
  ::  now we want to find the delta? or I guess we can just
  ::  have specific logic for each case.
  !!
  ::  helper core
  |%
  --
::  +get-weekday: gets weekday that a given date falls on.
::  implementation of sakamoto's method
::
++  get-weekday
  =<
  |=  da=@da
  ^-  weekday
  =/  =date  (yore da)
  =/  y=@ud  y.date
  =/  m=@ud  m.date
  =/  d=@ud  d.t.date
  ::  produces 0 for sunday, 1 for monday, etc.
  =/  idx=@ud
      =/  y=@ud
          ?:  (lth m 3)
            (dec y)
          y
      %+  mod
        %+  sub
          ;:  add
            y
            (div y 4)
            (div y 400)
            (~(got by month-table) m)
            d
          ==
        (div y 100)
      7
  (~(got by weekdays-by-idx) idx)
  |%
  ++  month-table
    ^-  (map @ud @ud)
    %-  ~(gas by *(map @ud @ud))
    :~
      [1 0]
      [2 3]
      [3 2]
      [4 5]
      [5 0]
      [6 3]
      [7 5]
      [8 1]
      [9 4]
      [10 6]
      [11 2]
      [12 4]
    ==
  --
--
