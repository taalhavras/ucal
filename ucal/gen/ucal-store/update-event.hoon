/-  *ucal-store
:-  %say
|=  [* [=calendar-code =event-code title=(unit @t) ~] ~]
:-  %ucal-action
^-  action
:*
  %update-event
  ^-  event-patch
  :*
    calendar-code
    event-code
    :: detail
    title
    ~ :: desc
    ~ :: loc
    :: other fields
    ~ :: when
    ~ :: era
    ~ :: tzid
  ==
==
