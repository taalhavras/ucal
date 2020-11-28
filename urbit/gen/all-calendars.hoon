/-  *ucal
:-  %say
|=  [[now=@da * bec=beak] ~ [who=(unit @p) ~]]
:-  %noun
=/  us=@tas  (scot %p p.bec)
=/  them=@tas
    ?~  who
      us
    (scot %p u.who)
=/  res=(list calendar)
    .^  (list calendar)
      %gy
      us
      %ucal-store
      (scot %da now)
      them
      %calendars
      ~
    ==
%+  turn
  res
|=  c=calendar
[%title title.c %code calendar-code.c %owner owner.c]
