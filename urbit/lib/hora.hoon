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
          ;:
            add
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
::  +days-in-month: number of days in a specified month of a specified year
::
++  days-in-month
  |=  [m=@ud y=@ud]
  ^-  @ud
  %+  snag
    (dec m)
  ?:  (yelp y)
    moy:yo
  moh:yo
::  +nth-weekday: gets nth weekday in target month
::
++  nth-weekday
  |=  [target=weekday m=@ud y=@ud instance=weekday-instance]
  ^-  @da
  =|  d=date
  =/  d=date  d(y y, m m, d 1)
  =/  da=@da  (year d)
  =/  start=weekday  (get-weekday da)
  ::  number of days to advance start of month by to get
  ::  to first instance of target
  =/  day-diff=@dr
      %+  mul
        ~d1
      =/  start-idx=@ud  (~(got by idx-by-weekday) start)
      =/  target-idx=@ud  (~(got by idx-by-weekday) target)
      ?:  (gte target-idx start-idx)
        (sub target-idx start-idx)
      (sub (add 7 target-idx) start-idx)
  =/  base=@da  (add da day-diff)
  ?-  instance
      %first
    base
  ::
      %second
    (add base ~d7)
  ::
      %third
    (add base ~d14)
  ::
      %fourth
    (add base ~d21)
  ::
      %last
    =/  fourth=@da  (add base ~d21)
    ::  now check if a fifth fits within
    ::  the bounds of this month
    =/  f-date=date  (yore fourth)
    ::  if adding a week onto fourth fits in the month, we have five
    ::  of this weekday in the month and should produce the fifth.
    ?:  (lte (add d.t.f-date 7) (days-in-month m.f-date y.f-date))
      (add fourth ~d7)
    fourth
  ==
::  +check-within-era: check if a new starting @da for a moment
::  generated as a successor falls in the era.
::
++  check-within-era
  |=  [cur-start=@da coeff=@ud =era-type]
  ^-  flag
  ?:  ?=([%until *] era-type)
    ::  TODO do we need to pass the era's start to do overlap
    ::  checks here? given that we don't care about end overlap
    ::  in this function I'm thinking no.
    (lth cur-start end.era-type)
  ?:  ?=([%instances *] era-type)
    ::  coeff incremented since the original moment is
    ::  an instance at coeff 0.
    (lte +(coeff) num.era-type)
  ?:  ?=([%infinite] era-type)
    &
  !!
::  +advance-months: advance a given date by n months. doesn't validate
::  whether or not the day is in the given month.
::
++  advance-months
  |=  [d=date n=@ud]
  ^-  date
  =/  [year-delta=@ud new-month=@ud]  (dvr n 12)
  d(m new-month, y (add y.d year-delta))
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
::  +move-moment-start: create a new moment with the same duration as the
::  input but with the new start date.
::
++  move-moment-start
  |=  [m=moment new-start=@da]
  ^-  moment
  ?:  ?=([%days *] m)
    [%days new-start n.m]
  ?:  ?=([%block *] m)
    [%block new-start span.m]
  ?:  ?=([%period *] m)
    =/  delta=@dr  (sub end.m start.m)
    [%period new-start (add new-start delta)]
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
::  +successor-in-range: finds moment with start time >= start and < end using
::  interval and rrule. produces that moment and the number of applications of
::  the rule that were needed to generate it.
::
++  successor-in-range
  =<
  |=  [start=@da end=@da m=moment =era]
  ^-  (unit [moment @ud])
  =/  validator  (bake (cury date-in-range [start end]) @da)
  =/  [m-start=@da m-end=@da]  (moment-to-range m)
  ?:  (gte m-start end)
    ~
  ?:  (gte m-start start)
    `m
  ?:  ?=([%daily] rrule.era)
    =/  increment=@dr  (mul ~d1 interval.era)
    =/  coeff=@ud  (get-coeff start m-start increment)
    =/  new-start=@da  (add m-start (mul coeff increment))
    ?.  &((validator new-start) (check-within-era new-start coeff type.era))
      ~
    `[(move-moment-start m new-start) coeff]
  ?:  ?=([%weekly *] rrule.era)
    ::  using 7 days as the increment, but will then need
    ::  some offset logic to handle different days
    =/  increment=@dr  (mul ~d7 interval.era)
    =/  coeff=@ud  (get-coeff start m-start increment)
    =/  new-start=@da  (add m-start (mul coeff increment))
    =/  new-start-day=weekday  (get-weekday new-start)
    =/  new-start-idx=@ud  (~(got by idx-by-weekday) new-start-day)
    ::  now check all days in the weekly rule to see if any
    ::  are in range. we get the negative delta for each
    =/  days=(list weekday)  ~(tap in days.rrule.era)
    =/  final-start=(unit @da)
        =|  acc=(unit @da)
        |-
        ?~  days
          acc
        =/  cur=weekday  i.days
        =/  cur-idx=@ud  (~(got by idx-by-weekday) cur)
        ::  we're only interested in days on or before new-start-day
        ::  so we treat all days as such.
        =/  day-diff=@dr
            %+  mul
              ~d1
            ?:  (lte cur-idx new-start-idx)
              (sub new-start-idx cur-idx)
            (sub (add new-start-idx 7) cur-idx)
        =/  adjusted-start=@da  (sub new-start day-diff)
        ?.  (validator adjusted-start)
          $(days t.days)
        ?~  acc
          $(acc `adjusted-start, days t.days)
        $(acc (some `@da`(min adjusted-start u.acc)), days t.days)
    ?~  final-start
      ~
    =/  count=@ud
        (weekly-increments u.final-start m-start days.rrule.era interval.era)
    ?.  (check-within-era u.final-start count type.era)
      ~
    `[(move-moment-start m u.final-start) count]
  ?:  ?=([%monthly *] rrule.era)
    =/  month-diff=@ud  (months-between start m-start)
    =/  coeff=@ud  (get-coeff month-diff 0 interval.era)
    =/  month-delta=@ud  (mul coeff interval.era)
    =/  m-start-date=date  (yore m-start)
    ?:  ?=([%on] form.rrule.era)
      =|  i=@ud
      |-
      =/  [year-delta=@ud month-delta=@ud]  (dvr (add month-delta i) 12)
      =/  new-month=@ud  (add d.m-start-date month-delta)
      =/  new-year=@ud  (add y.m-start-date year-delta)
      ?:  (lte d.t.m-start-date (days-in-month new-month new-year))
        =/  new-start=@da  (year m-start-date(m new-month, y new-year))
        =/  count=@ud
            (monthly-increments new-start m-start d.t.m-start-date interval.era)
        ?.  &((validator new-start) (check-within-era new-start count type.era))
          ~
        `[(move-moment-start m new-start) count]
      ::  TODO I think this is guaranteed to terminate, but I haven't
      ::  proved that yet. But I think addition under modulo is cyclic
      ::  so we'll eventually get back to the original or another
      ::  satisfying month.
      $(i (add i interval.era))
    ?:  ?=([%weekday *] form.rrule.era)
      ::  get current weekday
      =/  cur=weekday  (get-weekday m-start)
      =/  cur-idx=@ud  (~(got by idx-by-weekday) cur)
      =/  [year-delta=@ud month-delta=@ud]  (dvr month-delta 12)
      =/  new-month=@ud  (add d.m-start-date month-delta)
      =/  new-year=@ud  (add y.m-start-date year-delta)
      =/  new-start=@da
          (nth-weekday cur new-month new-year instance.form.rrule.era)
      ?>  =(cur (get-weekday new-start))
      ?.  &((validator new-start) (check-within-era new-start coeff type.era))
        ~
      `[(move-moment-start m new-start) coeff]
    !!
  ?:  ?=([%yearly] rrule.era)
    ::  TODO as implemented, yearly recurring events on feb 29th get
    ::  moved to march 1st - do we want to support different behavior?
    =/  start-date=date  (yore start)
    =/  m-start-date=date  (yore m-start)
    =/  coeff=@ud  (get-coeff y.start-date y.m-start-date interval.era)
    =/  new-year=@ud  (add y.m-start-date (mul coeff interval.era))
    =/  new-start=@da  (year m-start-date(y new-year))
    ?.  &((validator new-start) (check-within-era new-start coeff type.era))
      ~
    `[(move-moment-start m new-start) coeff]
  !!
  |%
  ::  +weekly-increments: given two dates, calculates the number of weekdays
  ::  in between them that are in days, incrementing the week by interval.
  ::  a must have been generated by applying a weekly recurrence rule to b
  ::
  ++  weekly-increments
    |=  [a=@da b=@da days=(set weekday) interval=@ud]
    ^-  @ud
    ?>  (gth a b)
    ::  get number of instances in between by counting full weeks
    ::  and multiplying by the number of days the event occurs per week
    ::  number of full weeks between the dates
    =/  week-diff=@ud  (mul (div (sub a b) (mul ~d7 interval)) ~(wyt in days))
    =/  target=weekday  (get-weekday a)
    =/  cur=weekday  (get-weekday b)
    ?:  =(target cur)
      ::  FIXME not sure this handles interval correctly, could be
      ::  same weekday but interval is wrong (week is off)
      week-diff
    =/  target-idx=@ud  (~(got by idx-by-weekday) target)
    =/  cur-idx=@ud  (~(got by idx-by-weekday) cur)
    =/  indices-between=(list @ud)
        ?:  (gth target-idx cur-idx)
          (gulf +(cur-idx) target-idx)
        ?>  (lth target-idx cur-idx)
        (weld (gulf 0 target-idx) (gulf +(cur-idx) 6))
    ?>  (lth (lent indices-between) 7)
    =|  acc=@ud
    |-
    ?~  indices-between
      (add acc week-diff)
    =/  new-acc=@ud
        ?:  (~(has in days) (~(got by weekdays-by-idx) i.indices-between))
          +(acc)
        acc
    $(acc new-acc, indices-between t.indices-between)
  ::  +monthly-increments: given two dates such that a > b,
  ::  count the number of times interval months are added to b until
  ::  it's geq a AND contains the specified day. If we add interval
  ::  and the resulting month doesn't contain day, then it isn't
  ::  counted.
  ::
  ::  FIXME is there a way to make this constant time?
  ++  monthly-increments
    |=  [a=@da b=@da day=@ud interval=@ud]
    ^-  @ud
    ?>  (gth a b)
    ?:  (lte day 28)
      (get-coeff (months-between a b) 0 interval)
    =/  d1=date
        =/  d=date  (yore a)
        d(d.t 1, h.t 0, m.t 0, s.t 0, f.t ~)
    =/  d2=date
        =/  d=date  (yore b)
        d(d.t 1, h.t 0, m.t 0, s.t 0, f.t ~)
    =|  acc=@ud
    ::  increment d2 until it's geq d1, counting how many intervals
    ::  were needed
    |-
    ::  check if years equal and month geq OR year greater
    ?:  |((gth y.d2 y.d1) &(=(y.d2 y.d1) (gte m.d2 m.d1)))
      acc
    =/  [year-delta=@ud new-month=@ud]  (dvr (add interval m.d2) 12)
    =/  new-year=@ud  (add y.d2 year-delta)
    =/  new-acc=@ud
        ?:  (gte (days-in-month new-month new-year) day)
          +(acc)
        acc
    $(acc new-acc, d2 d2(m new-month, y new-year))
  ::  +months-between: given two dates such that a > b,
  ::  get the number of months between them
  ::
  ++  months-between
    |=  [a=@da b=@da]
    ^-  @ud
    ?>  (gth a b)
    =/  d1=date  (yore a)
    =/  d2=date  (yore b)
    (sub (add m.d1 (mul (sub y.d1 y.d2) 12)) m.d2)
  ::  +get-coeff: given a > b, finds the lowest k such that b + kc >= a
  ::
  ::  TODO should this be wet or dry?
  ++  get-coeff
    |*  [a=@ b=@ c=@]
    ?>  (gth a b)
    =/  delta=@  (sub a b)
    =/  [quot=@ rem=@]  (dvr delta c)
    ?:  =(rem 0)
      quot
    +(quot)
  --
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
        =/  d=date  (advance-months (yore start) interval)
        ?-  form.rrule
            %on
          |-
          ?:  (lte d.t.d (days-in-month m.d y.d))
            (year d)
          $(d (advance-months d interval))
        ::
            %weekday
          (nth-weekday (get-weekday start) m.d y.d instance.form.rrule)
        ==
      ?:  ?=([%yearly] rrule)
        ::  this handles leap year cases more cleanly than
        ::  just adding ~d365 times interval.
        =/  d=date  (yore start)
        (year d(y (add y.d interval)))
      !!
  (move-moment-start m new-start)
::
++  starting-in-range
  |=  [start=@da end=@da m=moment =era]
  ^-  (list moment)
  =/  successor=(unit [moment @ud])  (successor-in-range start end m era)
  ?~  successor
    ~
  =/  cur=moment  -:u.successor
  =/  count=@ud  +:u.succssor
  =/  acc=(list moment)  ~[cur]
  |-
  =/  next=moment  (advance-moment cur interval.era rrule.era)
  =/  [n-start=@da n-end=@da]
  ?:  &((check-within-era n-start count type.era) (lth n-start end))
    $(acc [next acc], cur next, count +(count))
  acc
::
++  overlapping-in-range
  |=  [start=@da end=@da m=moment =era]
  ^-  (list moment)
  =/  [m-start=@da m-end=@da]  (moment-to-range m)
  ::  special case check for whether m and start/end look like
  ::  m-start --- start --- m-end --- end
  ::  in this case, the moment overlaps with the range even though
  ::  it doesn't start in it.
  ?:  &((lth m-start start) (lth m-end end) (gth m-end start))
    :-  m
    (starting-in-range start end m era)
  (starting-in-range start end m era)
::  +events-in-range: given a recurring event and a range, produce a list of
::  all events starting OVERLAPPING WITH the range [start, end)
::
++  events-in-range
  |=  [e=event start=@da end=@da]
  ^-  (list event)
  ?>  (lte start end)
  ?~  era.e
    =/  [event-start=@da event-end=@da]
        (moment-to-range moment.e)
    ?:  (ranges-overlap start end event-start event-end)
      ~[e]
    ~
  %+  turn
    (overlapping-in-range start end moment.e u.era.e)
  |=(m=moment e(moment m))
--
