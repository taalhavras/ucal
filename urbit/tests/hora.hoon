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
::
++  to-set
  |=  l=(list moment)
  ^-  (set moment)
  (~(gas in *(set moment)) l)
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
          `era`[`era-type`[%infinite ~] 1 daily]
        ==
      !>  ^-  (set moment)
      (~(put in *(set moment)) [%period ~2019.3.3..06.15.00 ~2019.3.3..06.45.00])
      ::  hit end of interval
      :-
        :*
          ~2019.3.3..06.00.00
          ~2019.3.8..07.00.00
          `moment`[%block ~2019.3.3..06.15.00 ~h1]
          `era`[`era-type`[%infinite ~] 2 daily]
        ==
      !>
      %-  to-set
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
      %-  to-set
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
      %-  to-set
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
    ::  TODO add tests using successor, {starting, overlapping}-in-range
    ::
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
        `era`[`era-type`[%infinite ~] 1 daily]
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
        `era`[`era-type`[%infinite ~] 100 daily]
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
      !>  (to-set (starting-in-range start end m era))
      res
    ::  case where first event overlaps but doesn't start in range
    %+  expect-eq
    !>
    %-  to-set
    %:  starting-in-range
      ~2016.11.22
      ~2017.7.12
      `moment`[%days ~2016.11.21 2]
      `era`[[%instances 4] 7 daily]
    ==
    !>
    %-  to-set
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
      !>  (to-set (overlapping-in-range start end m era))
      res
    ::  first event overlaps, so we include it
    %+  expect-eq
    !>
    %-  to-set
    %:  overlapping-in-range
      ~2016.11.22
      ~2017.7.12
      `moment`[%days ~2016.11.21 2]
      `era`[[%instances 4] 7 daily]
    ==
    !>
    %-  to-set
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
  ++  mwf  `(set weekday)`(~(gas in *(set weekday)) ~[%mon %wed %fri])
  ++  tth  `(set weekday)`(~(gas in *(set weekday)) ~[%tue %thu])
  ++  weekend  `(set weekday)`(~(gas in *(set weekday)) ~[%sat %sun])
  --
  ;:  weld
    ::  advance moment tests
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2020.8.3 1] 1 `rrule`[%weekly mwf])
      !>  `moment`[%days ~2020.8.5 1]
  ==
::
++  test-hora-monthly-recurrence  !!
::
++  test-hora-yearly-recurrence  !!
::
++  test-hora-leap-years  !!
--
