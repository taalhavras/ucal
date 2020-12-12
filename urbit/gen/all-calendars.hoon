/-  *ucal, ucal-hook
:-  %say
|=  [[now=@da * bec=beak] ~ [who=(unit @p) local=flag ~]]
:-  %noun
^-  (list metadata:ucal-hook)
=/  us=@tas  (scot %p p.bec)
=/  them=@tas
    ?~  who
      ::  if we're checking our own metadata, 'local'
      ::  shouldn't be passed
      ?>  local
      us
    (scot %p u.who)
?.  local
  :: get metadata from the pull-hook
  .^  (list metadata:ucal-hook)
    %gy
    us
    %ucal-pull-hook
    (scot %da now)
    %metadata
    them
    ~
  ==
::  get metadata from local store
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
^-  metadata:ucal-hook
[owner.c title.c calendar-code.c]
