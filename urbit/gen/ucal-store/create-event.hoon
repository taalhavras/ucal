/-  *ucal-store
:-  %say
|=  [[* * bec=beak] [=calendar-code title=@t when=moment ~] [event-code=(unit event-code) desc=(unit @t) loc=(unit location) era=(unit era) =invites tzid=(unit tape) ~]]
:-  %ucal-action
^-  action
:*
  %create-event
  calendar-code
  event-code
  p.bec
  `detail`[title desc loc]
  when
  era
  invites
  (fall tzid "utc")
==
