/-  *ucal-store
:-  %say
|=  [[* * bec=beak] [=calendar-code title=@t when=moment tzid=tape ~] [desc=(unit @t) loc=(unit location) era=(unit era) =invites ~]]
:-  %ucal-action
^-  action
:*
  %create-event
  calendar-code
  p.bec
  `detail`[title desc loc]
  when
  era
  invites
  tzid
==
