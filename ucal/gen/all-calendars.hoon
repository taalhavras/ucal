/-  *ucal, ucal-hook
:-  %say
|=  [[now=@da * bec=beak] ~ [who=(unit @p) local=flag ~]]
:-  %noun
^-  (list metadata:ucal-hook)
=/  us=@tas  (scot %p p.bec)
=/  them=@tas
    ?~  who
      ::  if we're checking our own metadata, 'local'
      ::  shouldn't be false.
      ?>  local
      us
    (scot %p u.who)
?.  local
  :: get metadata from the pull-hook
  :: .^  (list metadata:ucal-hook)
    :: %gx
    :: us
    :: %ucal-pull-hook
    :: (scot %da now)
    :: %metadata
    :: them
    :: /noun
  :: ==
::  get metadata from local store
=/  res=(list calendar)
    .^  (list calendar)
      %gx
      us
      %ucal-store
      (scot %da now)
      them
      /calendars/noun
    ==
%+  turn
  res
|=  c=calendar
^-  metadata:ucal-hook
[owner.c title.c calendar-code.c]
