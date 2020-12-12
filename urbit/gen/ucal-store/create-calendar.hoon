/-  *ucal-store
:-  %say
|=  [* [title=@t ~] [calendar-code=(unit calendar-code) readers=(unit (list @p)) writers=(unit (list @p)) ~]]
:-  %ucal-action
^-  action
[%create-calendar title calendar-code `calendar-permissions`[readers writers]]
