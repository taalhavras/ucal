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
  ;:  weld
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2019.1.1 1] 1 daily)
      !>  `moment`[%days ~2019.1.2 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%block ~2019.3.24 ~h4] 10 daily)
      !>  `moment`[%block ~2019.4.3 ~h4]
    %+  expect-eq
      !>  (advance-moment `moment`[%period s1 (add s1 ~m30)] 3 daily)
      !>  `moment`[%period (add s1 ~d3) ;:(add s1 ~d3 ~m30)]
  ==
--
