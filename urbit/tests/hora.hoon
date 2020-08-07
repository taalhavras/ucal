::  Tests for hora (recurring events)
::
/+  *test, *hora
::
::  Testing arms
::
|%
::  TODO how to handle constants? declare at top of testing arms?
::  have as separate arms? what makes the most sense?
::
::  failure val for successor-in-range, used for expect-eq
++  successor-fail  !>  *(unit [moment @ud])
::  constant for daily rules
++  daily  `rrule`[%daily ~]
::  constant for yearly rules
++  yearly  `rrule`[%yearly ~]
::  constant for infinite eras
++  infinite  `era-type`[%infinite ~]
::
++  test-hora-daily-recurrence
  =>
  |%
  ::  list of params and results that starting-in-range and overlapping-in-range
  ::  should produce the same results for.
  ++  starting-no-overlap
    ^-  (list [[@da @da moment era] vase])
    :~
      ::  first instance is the only thing in range
      :-
        :*
          ~2019.3.3..06.00.00
          ~2019.3.3..07.00.00
          `moment`[%period ~2019.3.3..06.15.00 ~2019.3.3..06.45.00]
          `era`[infinite 1 daily]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%period ~2019.3.3..06.15.00 ~2019.3.3..06.45.00])
      ::  hit end of interval
      :-
        :*
          ~2019.3.3..06.00.00
          ~2019.3.8..07.00.00
          `moment`[%block ~2019.3.3..06.15.00 ~h1]
          `era`[infinite 2 daily]
        ==
      !>
      %-  silt
      ^-  (list moment)
      :~
        [%block ~2019.3.3..06.15.00 ~h1]
        [%block ~2019.3.5..06.15.00 ~h1]
        [%block ~2019.3.7..06.15.00 ~h1]
      ==
      ::  hit end of era (instances)
      :-
        :*
          ~2018.4.17
          ~2019.4.17
          `moment`[%days ~2018.4.19 1]
          `era`[`era-type`[%instances 4] 2 daily]
        ==
      !>
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2018.4.19 1]
        [%days ~2018.4.21 1]
        [%days ~2018.4.23 1]
        [%days ~2018.4.25 1]
      ==
      ::  hit end of era (time)
      :-
        :*
          ~2018.4.17
          ~2019.4.17
          `moment`[%days ~2018.4.19 1]
          `era`[[%until ~2018.4.23] 2 daily]
        ==
      !>
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2018.4.19 1]
        [%days ~2018.4.21 1]
      ==
    ==
  --
  =/  until=era-type  [%until ~2020.5.1]
  =/  s1=@da  ~2030.4.9..04.30.00
  ;:  weld
    ::  advance-moment tests
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2019.1.1 1] 1 daily)
      !>  `moment`[%days ~2019.1.2 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%block ~2019.3.24 ~h4] 10 daily)
      !>  `moment`[%block ~2019.4.3 ~h4]
    %+  expect-eq
      !>  (advance-moment `moment`[%period s1 (add s1 ~m30)] 3 daily)
      !>  `moment`[%period (add s1 ~d3) ;:(add s1 ~d3 ~m30)]
    ::  era ends before target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.1.1
        ~2020.10.1
        `moment`[%days ~2019.12.3 1]
        `era`[`era-type`[%until ~2019.12.24] 10 daily]
      ==
      successor-fail
    ::  moment starts after target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2017.5.23
        ~2019.8.4
        `moment`[%block ~2019.10.3..04.30.00 ~m30]
        `era`[infinite 1 daily]
      ==
      successor-fail
    ::  requires too many applications of the rule
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.2.14
        ~2020.8.20
        `moment`[%period ~2018.2.14..03.15.00 ~2018.2.14..05.30.00]
        `era`[`era-type`[%instances 20] 17 daily]
      ==
      successor-fail
    ::  last instance of event is in range
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2020.2.3
        ~2020.2.7
        `moment`[%block ~2020.1.19..20.00.00 ~h1]
        `era`[`era-type`[%instances 4] 5 daily]
      ==
      !>  [`moment`[%block ~2020.2.3..20.00.00 ~h1] 3]
    ::  no events generate within the target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.11.3
        ~2020.11.10
        `moment`[%days ~2020.9.3 3]
        `era`[infinite 100 daily]
      ==
      successor-fail
    ::  initial moment overlaps with target
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2020.2.3
        ~2020.2.24
        `moment`[%days ~2020.2.1 3]
        `era`[[%instances 2] 10 daily]
      ==
      !>  [`moment`[%days ~2020.2.11 3] 1]
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.2.3
        ~2020.2.24
        `moment`[%days ~2020.2.1 3]
        `era`[[%instances 1] 10 daily]
      ==
      successor-fail
    ::  general cases
    ::  TODO add more
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2020.1.1
        ~2020.10.1
        `moment`[%days ~2019.12.3 1]
        `era`[`era-type`[%until ~2020.4.9] 10 daily]
      ==
      !>  [`moment`[%days ~2020.1.2 1] 3]
    ::  starting-in-range tests
    ::
    ^-  tang
    %-  zing
    %+  turn
      starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
    %+  expect-eq
      !>  (silt (starting-in-range start end m era))
      res
    ::  case where first event overlaps but doesn't start in range
    %+  expect-eq
    !>
    %-  silt
    ^-  (list moment)
    %:  starting-in-range
      ~2016.11.22
      ~2017.7.12
      `moment`[%days ~2016.11.21 2]
      `era`[[%instances 4] 7 daily]
    ==
    !>
    %-  silt
    ^-  (list moment)
    :~
      [%days ~2016.11.28 2]
      [%days ~2016.12.5 2]
      [%days ~2016.12.12 2]
    ==
    ::  repeat earlier tests of starting-in-range with overlapping-in-range
    ^-  tang
    %-  zing
      %+  turn
    starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
    %+  expect-eq
      !>  (silt (overlapping-in-range start end m era))
      res
    ::  first event overlaps, so we include it
    %+  expect-eq
    !>
    %-  silt
    ^-  (list moment)
    %:  overlapping-in-range
      ~2016.11.22
      ~2017.7.12
      `moment`[%days ~2016.11.21 2]
      `era`[[%instances 4] 7 daily]
    ==
    !>
    %-  silt
    ^-  (list moment)
    :~
      [%days ~2016.11.21 2]
      [%days ~2016.11.28 2]
      [%days ~2016.12.5 2]
      [%days ~2016.12.12 2]
    ==
  ==
::
++  test-hora-weekly-recurrence
  =>
  |%
  ++  mwf  `rrule`[%weekly (silt `(list weekday)`~[%mon %wed %fri])]
  ++  tth  `rrule`[%weekly (silt `(list weekday)`~[%tue %thu])]
  ++  weekend  `rrule`[%weekly (silt `(list weekday)`~[%sat %sun])]
  ++  all-days
    ^-  rrule
    :-  %weekly
    %-  silt
    ^-  (list weekday)
    ~[%mon %tue %wed %thu %fri %sat %sun]
  ++  starting-no-overlap
    ^-  (list [[@da @da moment era] vase])
    :~
      ::  nothing in query range
      :-
        :*
          ~2020.8.11
          ~2020.8.14
          `moment`[%days ~2020.8.8 1]
          `era`[infinite 1 weekend]
        ==
      !>  *(set moment)
      ::  nothing in era (time)
      :-
        :*
          ~2020.8.20
          ~2020.8.31
          `moment`[%days ~2020.8.5 1]
          `era`[[%until ~2020.8.15] 1 mwf]
        ==
      !>  *(set moment)
      ::  nothing in era (instances)
      :-
        :*
          ~2020.8.24
          ~2020.8.31
          `moment`[%block ~2020.8.3..14.00.00 ~h2]
          `era`[[%instances 8] 1 mwf]
        ==
      !>  *(set moment)
      ::  first instance is the only thing in range
      :-
        :*
          ~2020.8.4
          ~2020.8.6
          `moment`[%block ~2020.8.5..18.00.00 ~h1.m30]
          `era`[infinite 1 mwf]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%block ~2020.8.5..18.00.00 ~h1.m30])
      ::  only one instance falls in the range
      :-
        :*
          ~2020.8.4
          ~2020.8.6
          `moment`[%block ~2020.8.3..18.00.00 ~h1.m30]
          `era`[infinite 1 mwf]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%block ~2020.8.5..18.00.00 ~h1.m30])
      ::  hit end of query range
      :-
        :*
          ~2020.8.16
          ~2020.8.22
          `moment`[%days ~2020.8.3 1]
          `era`[infinite 1 mwf]
        ==
      !>  ^-  (set moment)
      %-  silt
      `(list moment)`~[[%days ~2020.8.17 1] [%days ~2020.8.19 1] [%days ~2020.8.21 1]]
      ::  hit end of era (instances)
      :-
        :*
          ~2020.8.1
          ~2020.9.7
          `moment`[%days ~2020.8.1 1]
          `era`[[%instances 4] 1 [%weekly (~(put in *(set weekday)) %sat)]]
        ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.8.1 1]
        [%days ~2020.8.8 1]
        [%days ~2020.8.15 1]
        [%days ~2020.8.22 1]
      ==
      ::  hit end of era (time)
      :-
        :*
          ~2020.8.1
          ~2020.8.31
          `moment`[%days ~2020.8.4 1]
          `era`[[%until ~2020.8.13] 1 tth]
        ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.8.4 1]
        [%days ~2020.8.6 1]
        [%days ~2020.8.11 1]
      ==
      ::  interval greater than 1
      ::  :-
      ::    :*
      ::    ==
      ::  !>  ^-  (set moment)
      ::  !!
    ==
  --
  ;:  weld
    ::  advance moment tests
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.3 1] 1 mwf)
      !>  `moment`[%days ~2020.8.5 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.4 2] 1 tth)
      !>  `moment`[%days ~2020.8.6 2]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.6 2] 1 tth)
      !>  `moment`[%days ~2020.8.11 2]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.4 2] 2 tth)
      !>  `moment`[%days ~2020.8.6 2]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.6 2] 2 tth)
      !>  `moment`[%days ~2020.8.18 2]
    %+  expect-eq
      !>  (advance-moment `moment`[%block ~2020.8.8..06.30.00 ~h2] 1 weekend)
      !>  `moment`[%block ~2020.8.9..06.30.00 ~h2]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.30 1] 1 all-days)
      !>  `moment`[%days ~2020.8.31 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.31 1] 1 all-days)
      !>  `moment`[%days ~2020.9.1 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.1 1] 1 all-days)
      !>  `moment`[%days ~2020.9.2 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.2 1] 1 all-days)
      !>  `moment`[%days ~2020.9.3 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.3 1] 1 all-days)
      !>  `moment`[%days ~2020.9.4 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.4 1] 1 all-days)
      !>  `moment`[%days ~2020.9.5 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.5 1] 1 all-days)
      !>  `moment`[%days ~2020.9.6 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.6 1] 1 all-days)
      !>  `moment`[%days ~2020.9.7 1]
    ::  two week intervals
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.30 1] 2 all-days)
      !>  `moment`[%days ~2020.8.31 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.31 1] 2 all-days)
      !>  `moment`[%days ~2020.9.1 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.1 1] 2 all-days)
      !>  `moment`[%days ~2020.9.2 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.2 1] 2 all-days)
      !>  `moment`[%days ~2020.9.3 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.3 1] 2 all-days)
      !>  `moment`[%days ~2020.9.4 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.4 1] 2 all-days)
      !>  `moment`[%days ~2020.9.5 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.5 1] 2 all-days)
      !>  `moment`[%days ~2020.9.13 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.13 1] 2 all-days)
      !>  `moment`[%days ~2020.9.14 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.9.6 1] 2 all-days)
      !>  `moment`[%days ~2020.9.7 1]
    ::  successor in range tests
    ::
    ::  era ends before target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.1
        ~2020.8.31
        `moment`[%days ~2020.7.23 1]
        `era`[[%until ~2020.7.30] 1 tth]
      ==
      successor-fail
    ::  moment starts after target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.1
        ~2020.8.31
        `moment`[%days ~2020.9.1 1]
        `era`[infinite 1 tth]
      ==
      successor-fail
    ::  too many applications of rule
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.18
        ~2020.8.31
        `moment`[%days ~2020.8.3 1]
        `era`[[%instances 5] 1 mwf]
      ==
      successor-fail
    ::  no events in target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.4
        ~2020.8.5
        `moment`[%days ~2020.8.3 1]
        `era`[infinite 1 [%weekly (silt `(list weekday)`~[%mon %thu %fri])]]
      ==
      successor-fail
    ::  initial moment overlaps with range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.9..04.00.00
        ~2020.8.25
        `moment`[%block ~2020.8.8..23.00.00 ~h6]
        `era`[[%instances 1] 1 [%weekly (silt `(list weekday)`~[%sat %tue])]]
      ==
      successor-fail
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2020.8.9..04.00.00
        ~2020.8.25
        `moment`[%block ~2020.8.8..23.00.00 ~h6]
        `era`[[%instances 2] 1 [%weekly (silt `(list weekday)`~[%sat %tue])]]
      ==
      !>  [`moment`[%block ~2020.8.11..23.00.00 ~h6] 1]
    ::  general cases
    ::  TODO add more?
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2020.8.12
        ~2020.8.26
        `moment`[%block ~2020.8.13..12.00.00 ~h2]
        `era`[infinite 1 tth]
      ==
      !>  [`moment`[%block ~2020.8.13..12.00.00 ~h2] 0]
    ::  last instance falls in range
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2020.8.21
        ~2020.8.31
        `moment`[%block ~2020.8.1..04.00.00 ~m30]
        `era`[[%instances 7] 1 weekend]
      ==
      !>  [`moment`[%block ~2020.8.22..04.00.00 ~m30] 6]
    ::  TODO {starting, overlapping}-in-range tests
    ^-  tang
    %-  zing
    %+  turn
      starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
    %+  expect-eq
      !>  (silt (starting-in-range start end m era))
      res
    ^-  tang
    %-  zing
    %+  turn
      starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
    %+  expect-eq
      !>  (silt (overlapping-in-range start end m era))
      res
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.8.4..12.00.00
        ~2020.8.8..18.00.00
        `moment`[%block ~2020.8.4..10.00.00 ~h3]
        `era`[infinite 1 tth]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%block ~2020.8.4..10.00.00 ~h3]
        [%block ~2020.8.6..10.00.00 ~h3]
      ==
  ==
::
++  test-hora-monthly-recurrence
  =>
  |%
  ++  on  `monthly`[%on ~]
  ++  starting-no-overlap
    ^-  (list [[@da @da moment era] vase])
    :~
      ::  nothing in query range
      :-
        :*
          ~2015.2.23
          ~2015.4.26
          `moment`[%days ~2016.3.25 3]
          `era`[infinite 1 [%monthly on]]
        ==
      !>  *(set moment)
      ::  nothing in era (time)
      :-
        :*
          ~2019.1.23
          ~2020.2.4
          `moment`[%days ~2017.5.14 1]
          `era`[[%until ~2019.1.1] 1 [%monthly on]]
        ==
      !>  *(set moment)
      ::  nothing in era (instances)
      :-
        :*
          ~2020.9.4
          ~2020.12.2
          `moment`[%days ~2014.10.9 1]
          `era`[[%instances 20] 1 [%monthly on]]
        ==
      !>  *(set moment)
      ::  first instance is the only thing in range
      ::  only one instance falls in the range
      ::  hit end of query range
      ::  hit end of era (instances)
      ::  hit end of era (time)
    ==
  --
  ;:  weld
    ::  advance-moment tests
    %+  expect-eq
      !>  (advance-moment [%days ~2020.8.11 1] 1 [%monthly on])
      !>  `moment`[%days ~2020.9.11 1]
    %+  expect-eq
      !>  (advance-moment [%days ~2020.8.11 1] 1 [%monthly %weekday %second])
      !>  `moment`[%days ~2020.9.8 1]
    ::  skips over months where day isn't present
    %+  expect-eq
      !>  (advance-moment [%days ~2020.1.31 1] 1 [%monthly on])
      !>  `moment`[%days ~2020.3.31 1]
    %+  expect-eq
      !>  (advance-moment [%days ~2019.12.30 1] 2 [%monthly on])
      !>  `moment`[%days ~2020.4.30 1]
    %+  expect-eq
      !>  (advance-moment [%days ~2019.12.31 1] 2 [%monthly on])
      !>  `moment`[%days ~2020.8.31 1]
    ::  difference between %fourth and %last
    %+  expect-eq
      !>  (advance-moment [%days ~2020.7.25 1] 1 [%monthly %weekday %fourth])
      !>  `moment`[%days ~2020.8.22 1]
    %+  expect-eq
      !>  (advance-moment [%days ~2020.7.25 1] 1 [%monthly %weekday %last])
      !>  `moment`[%days ~2020.8.29 1]
    ::  TODO successor-in-range tests? worth? probably right?
    ::  end of range
    ::  end of era (instances)
    ::  end of era (time)
    ::  overlapping instance
    ::  %+  expect-eq
    ::    !>
    ::    %-  need

    ::  {starting, overlapping}-in-range tests
    ^-  tang
    %-  zing
    %+  turn
      starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
    %+  expect-eq
      !>  (silt (starting-in-range start end m era))
      res
    ^-  tang
    %-  zing
    %+  turn
      starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
      %+  expect-eq
      !>  (silt (overlapping-in-range start end m era))
      res
    ::  just the overlapping event is present
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.3.4
        ~2020.3.28
        `moment`[%days ~2020.3.2 3]
        `era`[infinite 1 [%monthly on]]
      ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%days ~2020.3.2 3])
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.3.4
        ~2020.3.28
        `moment`[%days ~2020.3.2 3]
        `era`[infinite 1 [%monthly [%weekday %first]]]
      ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%days ~2020.3.2 3])
    ::  overlapping and others present
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.5.20
        ~2020.8.3
        `moment`[%days ~2020.5.19 3]
        `era`[infinite 1 [%monthly on]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.5.19 3]
        [%days ~2020.6.19 3]
        [%days ~2020.7.19 3]
      ==
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.11.4
        ~2021.3.3
        `moment`[%days ~2020.11.1 4]
        `era`[infinite 1 [%monthly %weekday %first]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.11.1 4]
        [%days ~2020.12.6 4]
        [%days ~2021.1.3 4]
        [%days ~2021.2.7 4]
      ==
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.5.20
        ~2020.8.3
        `moment`[%days ~2020.5.19 3]
        `era`[infinite 1 [%monthly %weekday %third]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.5.19 3]
        [%days ~2020.6.16 3]
        [%days ~2020.7.21 3]
      ==
    ::  overlapping hits end of era (instances)
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.3.20
        ~2020.5.21
        `moment`[%days ~2020.3.17 4]
        [[%instances 2] 1 [%monthly on]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.3.17 4]
        [%days ~2020.4.17 4]
      ==
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.3.20
        ~2020.5.21
        `moment`[%days ~2020.3.17 4]
        [[%instances 3] 1 [%monthly on]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.3.17 4]
        [%days ~2020.4.17 4]
        [%days ~2020.5.17 4]
      ==
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.1.31
        ~2020.5.30
        `moment`[%days ~2020.1.30 4]
        [[%instances 3] 1 [%monthly on]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.1.30 4]
        [%days ~2020.3.30 4]
        [%days ~2020.4.30 4]
      ==
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.3.20
        ~2020.5.21
        `moment`[%days ~2020.3.17 4]
        [[%instances 1] 1 [%monthly on]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.3.17 4]
      ==
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.11.4
        ~2021.3.3
        `moment`[%days ~2020.11.1 4]
        `era`[[%instances 1] 1 [%monthly %weekday %first]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.11.1 4]
      ==
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.5.20
        ~2020.8.3
        `moment`[%days ~2020.5.19 3]
        `era`[[%instances 2] 1 [%monthly %weekday %third]]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.5.19 3]
        [%days ~2020.6.16 3]
      ==
  ==
::
++  test-hora-yearly-recurrence  !!
::
::  TODO do we want this separately? I think so...
++  test-hora-leap-years  !!
::  test queries on ranges that start/end at the same times as events
++  test-event-boundaries  !!
--
