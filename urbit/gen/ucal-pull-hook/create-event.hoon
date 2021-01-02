/-  *ucal-store, ucal-hook
:-  %say
|=  [[* * bec=beak] [=calendar-code title=@t when=moment ~] [on=(unit @p) event-code=(unit event-code) desc=(unit @t) loc=(unit location) era=(unit era) =invites tzid=(unit tape) ~]]
:-  %ucal-hook-action
^-  action:ucal-hook
:+  %proxy-poke
  (fall on p.bec)
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
