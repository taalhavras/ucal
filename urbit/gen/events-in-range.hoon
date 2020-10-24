/-  *ucal
:-  %say
|=  [[now=@da * bec=beak] [=calendar-code start=@da end=@da ~] ~]
:-  %noun
=/  res=[(list event) (list projected-event)]
    .^  [(list event) (list projected-event)]
      %gy
      (scot %p p.bec)
      %ucal-store
      (scot %da now)
      %events
      %inrange
      (scot %ud calendar-code)
      (scot %da start)
      (scot %da end)
      ~
    ==
res
