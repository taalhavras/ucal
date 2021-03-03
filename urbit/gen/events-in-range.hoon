/-  *ucal
:-  %say
|=  [[now=@da * bec=beak] [=calendar-code start=@da end=@da ~] [who=(unit @p) ~]]
:-  %noun
=/  us=@tas  (scot %p p.bec)
=/  them=@tas
    ?~  who
      us
    (scot %p u.who)
=/  res=[(list event) (list projected-event)]
    .^  [(list event) (list projected-event)]
      %gx
      us
      %ucal-store
      (scot %da now)
      them
      %events
      %inrange
      (scot %tas calendar-code)
      (scot %da start)
      (scot %da end)
      %noun
      ~
    ==
res
