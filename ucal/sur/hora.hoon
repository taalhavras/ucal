|%
::  $weekday: days of the week
::
+$  weekday
  $?  %mon
      %tue
      %wed
      %thu
      %fri
      %sat
      %sun
  ==
::  $month: months of the year
::
+$  month
  $?  %jan
      %feb
      %mar
      %apr
      %may
      %jun
      %jul
      %aug
      %sep
      %oct
      %nov
      %dec
  ==
::  +month-to-idx: map of month to index (1-12)
::
++  month-to-idx
  ^-  (map month @ud)
  %-  malt
  ^-  (list [month @ud])
  :~  [%jan 1]
      [%feb 2]
      [%mar 3]
      [%apr 4]
      [%may 5]
      [%jun 6]
      [%jul 7]
      [%aug 8]
      [%sep 9]
      [%oct 10]
      [%nov 11]
      [%dec 12]
  ==
::
::  When the event will occur. Can be all day, relative to a start date, or have
::  an explicit start and end.
::
+$  moment
  $%  [%days start=@da n=$~(1 @ud)]                    :: all day for n days
                                                       :: n=1 means just for start
      [%block anchor=@da span=@dr]                     :: anchor & relative end
      [%period start=@da end=@da]                      :: definite start and end
  ==
::  $weekday-instance: instances of a weekday possible in a month
::
+$  weekday-instance  ?(%first %second %third %fourth %last)
::  $monthly: data needed for monthly recurrences.
::  either on a specific date (i.e. 27th) or on the nth weekday of a month
::
+$  monthly
  $%  [%on ~]
      [%weekday instance=weekday-instance]
  ==
::
+$  rrule
  $%  [%daily ~]
      ::  FIXME problem is these must all be timezone aware, so events
      ::  must track I guess. actually, maybe we can just assume all
      ::  times are local and do offsets at the top level calendar.
      [%weekly days=(set weekday)]
      ::  gcal offers nth day of the month or nth weekday of the month here
      ::  worth noting that gcal doesn't handle the case where nth day doesn't
      ::  occur in a month (it just skips over the month) - do we replicate?
      ::  perhaps we can offer a third option, one where it skips and one where
      ::  it doesn't?
      ::  FIXME this is probably gonna run into the problem where
      ::  successive applications of this rule move the date earlier.
      ::  i.e. jan 31st -> feb 28th -> mar 28th.
      ::  this problem is skirted in the case where we don't bother with
      ::  months that don't include the current day.
      ::  maybe we should just make include a signed day part of this or something?
      ::  like you can say 23rd day OR 7th day from end...
      [%monthly form=monthly]
      ::  yearly on the specified date
      [%yearly ~]
  ==
::
+$  era-type
  $%  [%until end=@da]
      [%instances num=@ud]
      [%infinite ~]
  ==
::  $era:  An era is our equivalent of a recurrence rule. The rrule component
::  determines the mechanism of the recurrence along with the interval, and
::  the type determines the era's bounds.
::
+$  era
  $:  type=era-type
      interval=$~(1 @ud)
      =rrule
  ==
--
