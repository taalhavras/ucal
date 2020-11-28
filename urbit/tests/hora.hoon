::  Tests for hora (recurring events)
::
/+  *test, *hora
::
::  Testing arms
::
|%
::  failure val for successor-in-range, used for expect-eq
::
++  successor-fail  !>  *(unit [moment @ud])
::  constant for daily rules
::
++  daily  `rrule`[%daily ~]
::  constant for yearly rules
::
++  yearly  `rrule`[%yearly ~]
::  constant for monthly rrules
::
++  on  `monthly`[%on ~]
::  constant for infinite eras
::
++  infinite  `era-type`[%infinite ~]
::  constant for empty exdates
::
++  nex  *(set @da)
::  a wrapper for advance-moment with no exdates - used to simplify testing.
::  we can discard count since it's always 1 with no exdates.
++  advance-moment-no-exdates
  |=  [m=moment interval=@ud =rrule]
  ^-  moment
  (head (advance-moment m interval rrule nex))
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
          `era`[infinite 1 daily nex]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%period ~2019.3.3..06.15.00 ~2019.3.3..06.45.00])
      ::  hit end of interval
      :-
        :*
          ~2019.3.3..06.00.00
          ~2019.3.8..07.00.00
          `moment`[%block ~2019.3.3..06.15.00 ~h1]
          `era`[infinite 2 daily nex]
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
          `era`[`era-type`[%instances 4] 2 daily nex]
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
          `era`[[%until ~2018.4.23] 2 daily nex]
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
    ::  advance-moment-no-exdates tests
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2019.1.1 1] 1 daily)
      !>  `moment`[%days ~2019.1.2 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%block ~2019.3.24 ~h4] 10 daily)
      !>  `moment`[%block ~2019.4.3 ~h4]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%period s1 (add s1 ~m30)] 3 daily)
      !>  `moment`[%period (add s1 ~d3) ;:(add s1 ~d3 ~m30)]
    ::  era ends before target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.1.1
        ~2020.10.1
        `moment`[%days ~2019.12.3 1]
        `era`[`era-type`[%until ~2019.12.24] 10 daily nex]
      ==
      successor-fail
    ::  moment starts after target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2017.5.23
        ~2019.8.4
        `moment`[%block ~2019.10.3..04.30.00 ~m30]
        `era`[infinite 1 daily nex]
      ==
      successor-fail
    ::  requires too many applications of the rule
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.2.14
        ~2020.8.20
        `moment`[%period ~2018.2.14..03.15.00 ~2018.2.14..05.30.00]
        `era`[`era-type`[%instances 20] 17 daily nex]
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
        `era`[`era-type`[%instances 4] 5 daily nex]
      ==
      !>  [`moment`[%block ~2020.2.3..20.00.00 ~h1] 3]
    ::  no events generate within the target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.11.3
        ~2020.11.10
        `moment`[%days ~2020.9.3 3]
        `era`[infinite 100 daily nex]
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
        `era`[[%instances 2] 10 daily nex]
      ==
      !>  [`moment`[%days ~2020.2.11 3] 1]
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.2.3
        ~2020.2.24
        `moment`[%days ~2020.2.1 3]
        `era`[[%instances 1] 10 daily nex]
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
        `era`[`era-type`[%until ~2020.4.9] 10 daily nex]
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
      `era`[[%instances 4] 7 daily nex]
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
      `era`[[%instances 4] 7 daily nex]
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
          `era`[infinite 1 weekend nex]
        ==
      !>  *(set moment)
      ::  nothing in era (time)
      :-
        :*
          ~2020.8.20
          ~2020.8.31
          `moment`[%days ~2020.8.5 1]
          `era`[[%until ~2020.8.15] 1 mwf nex]
        ==
      !>  *(set moment)
      ::  nothing in era (instances)
      :-
        :*
          ~2020.8.24
          ~2020.8.31
          `moment`[%block ~2020.8.3..14.00.00 ~h2]
          `era`[[%instances 8] 1 mwf nex]
        ==
      !>  *(set moment)
      ::  first instance is the only thing in range
      :-
        :*
          ~2020.8.4
          ~2020.8.6
          `moment`[%block ~2020.8.5..18.00.00 ~h1.m30]
          `era`[infinite 1 mwf nex]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%block ~2020.8.5..18.00.00 ~h1.m30])
      ::  only one instance falls in the range
      :-
        :*
          ~2020.8.4
          ~2020.8.6
          `moment`[%block ~2020.8.3..18.00.00 ~h1.m30]
          `era`[infinite 1 mwf nex]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%block ~2020.8.5..18.00.00 ~h1.m30])
      ::  hit end of query range
      :-
        :*
          ~2020.8.16
          ~2020.8.22
          `moment`[%days ~2020.8.3 1]
          `era`[infinite 1 mwf nex]
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
          `era`[[%instances 4] 1 [%weekly (~(put in *(set weekday)) %sat)] nex]
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
          `era`[[%until ~2020.8.13] 1 tth nex]
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
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.3 1] 1 mwf)
      !>  `moment`[%days ~2020.8.5 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.4 2] 1 tth)
      !>  `moment`[%days ~2020.8.6 2]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.6 2] 1 tth)
      !>  `moment`[%days ~2020.8.11 2]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.4 2] 2 tth)
      !>  `moment`[%days ~2020.8.6 2]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.6 2] 2 tth)
      !>  `moment`[%days ~2020.8.18 2]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%block ~2020.8.8..06.30.00 ~h2] 1 weekend)
      !>  `moment`[%block ~2020.8.9..06.30.00 ~h2]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.30 1] 1 all-days)
      !>  `moment`[%days ~2020.8.31 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.31 1] 1 all-days)
      !>  `moment`[%days ~2020.9.1 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.1 1] 1 all-days)
      !>  `moment`[%days ~2020.9.2 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.2 1] 1 all-days)
      !>  `moment`[%days ~2020.9.3 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.3 1] 1 all-days)
      !>  `moment`[%days ~2020.9.4 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.4 1] 1 all-days)
      !>  `moment`[%days ~2020.9.5 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.5 1] 1 all-days)
      !>  `moment`[%days ~2020.9.6 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.6 1] 1 all-days)
      !>  `moment`[%days ~2020.9.7 1]
    ::  two week intervals
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.30 1] 2 all-days)
      !>  `moment`[%days ~2020.8.31 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.8.31 1] 2 all-days)
      !>  `moment`[%days ~2020.9.1 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.1 1] 2 all-days)
      !>  `moment`[%days ~2020.9.2 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.2 1] 2 all-days)
      !>  `moment`[%days ~2020.9.3 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.3 1] 2 all-days)
      !>  `moment`[%days ~2020.9.4 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.4 1] 2 all-days)
      !>  `moment`[%days ~2020.9.5 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.5 1] 2 all-days)
      !>  `moment`[%days ~2020.9.13 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.13 1] 2 all-days)
      !>  `moment`[%days ~2020.9.14 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates `moment`[%days ~2020.9.6 1] 2 all-days)
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
        `era`[[%until ~2020.7.30] 1 tth nex]
      ==
      successor-fail
    ::  moment starts after target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.1
        ~2020.8.31
        `moment`[%days ~2020.9.1 1]
        `era`[infinite 1 tth nex]
      ==
      successor-fail
    ::  too many applications of rule
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.18
        ~2020.8.31
        `moment`[%days ~2020.8.3 1]
        `era`[[%instances 5] 1 mwf nex]
      ==
      successor-fail
    ::  no events in target range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.4
        ~2020.8.5
        `moment`[%days ~2020.8.3 1]
        `era`[infinite 1 [%weekly (silt `(list weekday)`~[%mon %thu %fri])] nex]
      ==
      successor-fail
    ::  initial moment overlaps with range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.9..04.00.00
        ~2020.8.25
        `moment`[%block ~2020.8.8..23.00.00 ~h6]
        `era`[[%instances 1] 1 [%weekly (silt `(list weekday)`~[%sat %tue])] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2020.8.9..04.00.00
        ~2020.8.25
        `moment`[%block ~2020.8.8..23.00.00 ~h6]
        `era`[[%instances 2] 1 [%weekly (silt `(list weekday)`~[%sat %tue])] nex]
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
        `era`[infinite 1 tth nex]
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
        `era`[[%instances 7] 1 weekend nex]
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
        `era`[infinite 1 tth nex]
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
  ++  starting-no-overlap
    ^-  (list [[@da @da moment era] vase])
    :~
      ::  nothing in query range
      :-
        :*
          ~2015.2.23
          ~2015.4.26
          `moment`[%days ~2016.3.25 3]
          `era`[infinite 1 [%monthly on] nex]
        ==
      !>  *(set moment)
      ::  nothing in era (time)
      :-
        :*
          ~2019.1.23
          ~2020.2.4
          `moment`[%days ~2017.5.14 1]
          `era`[[%until ~2019.1.1] 1 [%monthly on] nex]
        ==
      !>  *(set moment)
      ::  nothing in era (instances)
      :-
        :*
          ~2020.9.4
          ~2020.12.2
          `moment`[%days ~2014.10.9 1]
          `era`[[%instances 20] 1 [%monthly on] nex]
        ==
      !>  *(set moment)
      :-
        :*
          ~2020.9.4
          ~2020.12.2
          `moment`[%days ~2014.10.9 1]
          `era`[[%instances 20] 1 [%monthly %weekday %second] nex]
        ==
      !>  *(set moment)
      ::  first instance is the only thing in range
      :-
        :*
          ~2013.8.5
          ~2014.3.2
          `moment`[%days ~2014.1.29 1]
          `era`[[%instances 10] 1 monthly+on nex]
        ==
      !>  (~(put in *(set moment)) `moment`[%days ~2014.1.29 1])
      :-
        :*
          ~2013.8.5
          ~2014.2.2
          `moment`[%days ~2014.1.29 1]
          `era`[[%instances 10] 1 [%monthly %weekday %last] nex]
        ==
      !>  (~(put in *(set moment)) `moment`[%days ~2014.1.29 1])
      ::  only one instance falls in the range
      :-
        :*
          ~2014.2.2
          ~2014.3.2
          `moment`[%days ~2014.1.5 1]
          `era`[[%instances 10] 1 monthly+on nex]
        ==
      !>  (~(put in *(set moment)) `moment`[%days ~2014.2.5 1])
      :-
        :*
          ~2020.3.4..10.00.00
          ~2020.4.10
          `moment`[%block ~2020.3.4..07.00.00 ~h2]
          `era`[infinite 1 monthly+on nex]
        ==
      !>  (~(put in *(set moment)) `moment`[%block ~2020.4.4..07.00.00 ~h2])
      ::  hit end of query range
      ::  hit end of era (instances)
      ::  hit end of era (time)
    ==
  --
  ;:  weld
    ::  advance-moment-no-exdates tests
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2020.8.11 1] 1 [%monthly on])
      !>  `moment`[%days ~2020.9.11 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2020.8.11 1] 1 [%monthly %weekday %second])
      !>  `moment`[%days ~2020.9.8 1]
    %+  expect-eq
      !>
      %:  advance-moment-no-exdates
        `moment`[%block ~2020.1.1..10.00.00 ~m30]
        1
        `rrule`[%monthly %weekday %first]
      ==
      !>  `moment`[%block ~2020.2.5..10.00.00 ~m30]
    ::  skips over months where day isn't present
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2020.1.31 1] 1 [%monthly on])
      !>  `moment`[%days ~2020.3.31 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2019.12.30 1] 2 [%monthly on])
      !>  `moment`[%days ~2020.4.30 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2019.12.31 1] 2 [%monthly on])
      !>  `moment`[%days ~2020.8.31 1]
    ::  difference between %fourth and %last
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2020.7.25 1] 1 [%monthly %weekday %fourth])
      !>  `moment`[%days ~2020.8.22 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2020.7.25 1] 1 [%monthly %weekday %last])
      !>  `moment`[%days ~2020.8.29 1]
    ::  successor-in-range tests
    ::  end of range
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.6.9
        ~2020.7.4
        `moment`[%days ~2020.6.7 1]
        `era`[infinite 1 [%monthly on] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.31
        ~2020.9.25
        `moment`[%days ~2020.8.29 1]
        `era`[infinite 1 [%monthly %weekday %last] nex]
      ==
      successor-fail
    ::  end of era (instances)
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.9.1
        ~2020.9.30
        `moment`[%days ~2020.1.31 1]
        `era`[[%instances 4] 1 [%monthly on] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.6.1
        ~2020.7.31
        `moment`[%days ~2020.1.31 1]
        `era`[[%instances 3] 1 [%monthly on] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.3.1
        ~2020.3.31
        `moment`[%days ~2020.1.1 1]
        `era`[[%instances 2] 1 [%monthly %weekday %first] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.5.2
        ~2020.12.4
        `moment`[%days ~2020.1.8 1]
        `era`[[%instances 4] 1 [%monthly %weekday %second] nex]
      ==
      successor-fail
    ::  end of era (time)
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.9.20
        ~2020.12.3
        `moment`[%days ~2020.2.25 1]
        `era`[[%until ~2020.8.3] 1 [%monthly on] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.9.20
        ~2020.12.3
        `moment`[%days ~2020.2.29 1]
        `era`[[%until ~2020.8.3] 1 [%monthly %weekday %last] nex]
      ==
      successor-fail
    ::  overlapping instance
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.3
        ~2021.4.2
        `moment`[%block ~2020.8.2..23.00.00 ~h2]
        `era`[[%instances 1] 1 [%monthly on] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2020.8.3
        ~2021.4.2
        `moment`[%block ~2020.8.2..23.00.00 ~h2]
        `era`[[%instances 1] 1 [%monthly %weekday %first] nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
      ~2020.8.3
      ~2021.4.2
      `moment`[%block ~2020.8.2..23.00.00 ~h2]
      `era`[[%instances 2] 1 [%monthly on] nex]
      ==
      !>  [`moment`[%block ~2020.9.2..23.00.00 ~h2] 1]
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
      ~2020.8.3
      ~2021.4.2
      `moment`[%block ~2020.8.2..23.00.00 ~h2]
      `era`[[%instances 2] 1 [%monthly %weekday %first] nex]
      ==
      !>  [`moment`[%block ~2020.9.6..23.00.00 ~h2] 1]
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
        `era`[infinite 1 [%monthly on] nex]
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
        `era`[infinite 1 [%monthly [%weekday %first]] nex]
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
        `era`[infinite 1 [%monthly on] nex]
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
        `era`[infinite 1 [%monthly %weekday %first] nex]
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
        `era`[infinite 1 [%monthly %weekday %third] nex]
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
        `era`[[%instances 2] 1 [%monthly on] nex]
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
        `era`[[%instances 3] 1 [%monthly on] nex]
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
        `era`[[%instances 3] 1 [%monthly on] nex]
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
        `era`[[%instances 1] 1 [%monthly on] nex]
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
        `era`[[%instances 1] 1 [%monthly %weekday %first] nex]
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
        `era`[[%instances 2] 1 [%monthly %weekday %third] nex]
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
++  test-hora-yearly-recurrence
  =>
  |%
  ++  starting-no-overlap
    ^-  (list [[@da @da moment era] vase])
    :~
      ::  first instance is the only thing in range
      :-
        :*
          ~2020.6.1
          ~2020.9.1
          `moment`[%days ~2020.7.1..04.00.00 1]
          `era`[infinite 1 yearly nex]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) `moment`[%days ~2020.7.1..04.00.00 1])
      ::  last instance is the only thing in range
      :-
        :*
          ~2020.1.1
          ~2020.1.31
          `moment`[%days ~2015.1.10 1]
          `era`[[%instances 6] 1 yearly nex]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) `moment`[%days ~2020.1.10 1])
      ::  only one instance falls in range
      :-
        :*
          ~2019.9.4
          ~2020.5.27
          `moment`[%days ~2017.10.2..23.59.59 1]
          `era`[infinite 2 yearly nex]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) `moment`[%days ~2019.10.2..23.59.59 1])
      ::  hit end of interval
      :-
        :*
          ~2016.1.1
          ~2020.1.1
          `moment`[%days ~2015.3.3 1]
          `era`[infinite 1 yearly nex]
        ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2016.3.3 1]
        [%days ~2017.3.3 1]
        [%days ~2018.3.3 1]
        [%days ~2019.3.3 1]
      ==
      ::  hit end of era (instances)
      :-
        :*
          ~2015.2.22
          ~2020.4.23
          `moment`[%days ~2015.3.3 1]
          `era`[[%instances 3] 1 yearly nex]
        ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2015.3.3 1]
        [%days ~2016.3.3 1]
        [%days ~2017.3.3 1]
      ==
      ::  hit end of era (time)
      :-
        :*
          ~2014.8.22
          ~2020.7.4
          `moment`[%days ~2015.6.20 1]
          `era`[[%until ~2019.4.2] 1 yearly nex]
        ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2015.6.20 1]
        [%days ~2016.6.20 1]
        [%days ~2017.6.20 1]
        [%days ~2018.6.20 1]
      ==
    ==
  --
  ;:  weld
    ::  advance-moment-no-exdates tests
    %+  expect-eq
      !>  (advance-moment-no-exdates [%days ~2020.1.1 1] 1 yearly)
      !>  `moment`[%days ~2021.1.1 1]
    %+  expect-eq
      !>  (advance-moment-no-exdates [%block ~2020.3.18..08.30.00 ~h2] 2 yearly)
      !>  `moment`[%block ~2022.3.18..08.30.00 ~h2]
    %+  expect-eq
      !>
      (advance-moment-no-exdates [%period ~2020.2.24..05.00.00 ~2020.2.24..09.15.00] 1 yearly)
      !>  `moment`[%period ~2021.2.24..05.00.00 ~2021.2.24..09.15.00]
    ::  TODO successor-in-range tests
    ::  initial moment overlaps
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2019.2.3
        ~2020.12.21
        `moment`[%days ~2019.2.2 2]
        `era`[[%instances 1] 1 yearly nex]
      ==
      successor-fail
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2019.2.3
        ~2020.12.21
        `moment`[%days ~2019.2.2 2]
        `era`[[%instances 2] 1 yearly nex]
      ==
      !>  [`moment`[%days ~2020.2.2 2] 1]
    ::  {starting, overlapping}-in-range tests
    ^-  tang
    %-  zing
    %+  turn
      starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
    %+  expect-eq
      !>  (silt (starting-in-range start end m era))
      res
    ::
    ^-  tang
    %-  zing
    %+  turn
      starting-no-overlap
    |=  [[start=@da end=@da m=moment =era] res=vase]
    %+  expect-eq
      !>  (silt (overlapping-in-range start end m era))
      res
    ::  TODO overlapping-in-range tests
    %+  expect-eq
      !>
      %-  silt
      %:  overlapping-in-range
        ~2020.4.2
        ~2022.5.9
        `moment`[%days ~2020.4.1 3]
        `era`[infinite 1 yearly nex]
      ==
      !>  ^-  (set moment)
      %-  silt
      ^-  (list moment)
      :~
        [%days ~2020.4.1 3]
        [%days ~2021.4.1 3]
        [%days ~2022.4.1 3]
      ==
  ==
::
::  TODO do we want this separately? I think so...
::  ++  test-hora-leap-years  !!
::  test queries on ranges that start/end at the same times as events
::  ++  test-event-boundaries  !!
++  test-specifics
  ;:  weld
    %+  expect-eq
    !>
    %-  need
    %:  successor-in-range
      ~2019.2.3
      ~2020.12.21
      `moment`[%days ~2019.2.2 2]
      `era`[[%instances 2] 1 yearly nex]
    ==
    !>  [`moment`[%days ~2020.2.2 2] 1]
  ==
::
++  test-exdates
  =<
  ;:  weld
    ::  single exdate - excluded irrespective of time
    %+  expect-eq
      !>
      %:  successor-in-range
        ~2019.2.3
        ~2020.2.3
        `moment`[%block ~2019.4.4..18.48.00 ~h2]
        ^-  era
        :^    [%instances 2]
            1
          yearly
        (~(put in nex) ~2019.4.4)
      ==
      successor-fail
    ::  multiple exdates skipped
    %+  expect-eq
      !>
      %-  need
      %:  successor-in-range
        ~2019.2.3
        ~2020.2.3
        `moment`[%block ~2019.4.4..18.48.00 ~h2]
      ^-  era
      :^    infinite
          1
        [%monthly on]
      (~(gas in nex) ~[~2019.4.4 ~2019.5.4 ~2019.6.4 ~2019.7.4])
      ==
      !>  [`moment`[%block ~2019.8.4..18.48.00 ~h2] 4]
    ::  overlapping-in-range tests:
    ::  special case initial overlap is excluded
    %+  expect-eq
      !>
      %-  silt
      ^-  (list moment)
      %:  overlapping-in-range
        ~2019.2.3..10.00.00
        ~2020.5.5
        `moment`[%block ~2019.2.3..9.30.00 ~h1]
        ^-  era
        :^    infinite
            1
          yearly
        (~(put in nex) ~2019.2.3)
      ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%block ~2020.2.3..9.30.00 ~h1])
    ::  general tests
    ::  %instances rules with exdates
    %+  expect-eq
      !>
      ^-  (set moment)
      %-  silt
      ^-  (list moment)
      %:  overlapping-in-range
        ~2020.1.1
        ~2035.1.1
        `moment`[%block ~2020.1.2 ~m30]
        ^-  era
        :^  [%instances 10]
            1
          yearly
        %-  ~(gas in nex)
        ~[~2021.1.2 ~2022.1.2 ~2024.1.2 ~2025.1.2 ~2029.1.2 ~2030.1.2]
      ==
      !>  ^-  (set moment)
      %-  ~(gas in *(set moment))
      ^-  (list moment)
      :~
        [%block ~2020.1.2 ~m30]
        [%block ~2023.1.2 ~m30]
        [%block ~2026.1.2 ~m30]
        [%block ~2027.1.2 ~m30]
        [%block ~2028.1.2 ~m30]
      ==
  ==
  |%
  --
--
