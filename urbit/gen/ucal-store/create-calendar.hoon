/-  *ucal-store
:-  %say
|=  [* [title=@t ~] [calendar-code=(unit calendar-code) readers=(unit (list @p)) writers=(list @p) acolytes=(list @p) ~]]
:-  %ucal-action
^-  action
:^    %create-calendar
    title
  calendar-code
^-  calendar-permissions
:+  (bind readers silt)
  (silt writers)
(silt acolytes)
