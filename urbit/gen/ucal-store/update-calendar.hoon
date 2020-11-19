/-  *ucal-store
:-  %say
|=  [* [=calendar-code owner=(unit @p) title=(unit @t) ~] ~]
:-  %ucal-action
^-  action
:*
  %update-calendar
  `calendar-patch`[owner calendar-code title]
==
