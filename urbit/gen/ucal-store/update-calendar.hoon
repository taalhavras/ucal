/-  *ucal-store
:-  %say
|=  [* [=calendar-code title=(unit @t) ~] ~]
:-  %ucal-action
^-  action
:*
  %update-calendar
  `calendar-patch`[calendar-code title]
==
