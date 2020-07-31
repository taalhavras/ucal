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
++  test-hora-daily-recurrence
  =/  daily=rrule  [%daily ~]
  =/  until=era-type  [%until ~2020.5.1]
  =/  s1=@da  ~2030.4.9..04.30.00
  =/  successor-fail  !>  *(unit [moment @ud])
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
    ::
    ::  general cases
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
  ==
::
++  test-hora-weekly-recurrence  !!
::
++  test-hora-monthly-recurrence  !!
::
++  test-hora-yearly-recurrence  !!
::
++  test-hora-leap-years  !!
--
