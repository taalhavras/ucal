/-  *ucal-store
:-  %say
|=  [[* * bec=beak] [=calendar-code title=@t when=moment ~] [event-code=(unit event-code) desc=(unit @t) loc=(unit location) era=(unit era) invited=(set @p) tzid=(unit tape) ~]]
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
  invited
  (fall tzid "utc")
==
