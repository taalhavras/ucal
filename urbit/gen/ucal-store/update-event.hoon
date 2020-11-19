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
    title
    :: detail
    ~ :: desc
    ~ :: loc
    ~ :: description
    :: other fields
    ~ :: when
    ~ :: era
    ~ :: tzid
  ==
==
