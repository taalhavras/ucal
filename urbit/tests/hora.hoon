::  Tests for hora (recurring events)
::
/+  *test, *hora
::
::  Testing arms
::
|%
++  test-hora-daily-recurrence
  =/  daily=rrule  [%daily ~]
  =/  until=era-type  [%until ~2020.5.1]
  ;:  weld
    %+  expect-eq
      !>  (advance-moment `moment`[%days ~2019.1.1 1] 1 daily)
      !>  `moment`[%days ~2019.1.2 1]
    %+  expect-eq
      !>  (advance-moment `moment`[%block ~2019.3.24 ~h4] 10 daily)
      !>  `moment`[%block ~2019.4.3 ~h4]
  ==
::  ::
::  ++  test-hora-fake
::    =/  a=@  100
::    ~&  %in-test-test
::    ;:  weld
::      %+  expect-eq
::        !>  a
::        !>  100
::      %+  expect-eq
::        !>  a
::        !>  99
::    ==
--
