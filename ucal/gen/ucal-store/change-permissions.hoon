/-  *ucal-store
:-  %say
=>
|%
+$  arg
  $@  flavor=term
      $:  who=@p
          role=(unit calendar-role)
      ==
--
|=  [* [=calendar-code =arg ~] ~]
:-  %ucal-action
^-  action
:-  %change-permissions
^-  permission-change
:-  calendar-code
?:  ?=([term] arg)
  ?:  =(%make-public flavor.arg)
    [%make-public ~]
  ?:  =(%make-private flavor.arg)
    [%make-private ~]
  ::  invalid option
  !!
[%change who.arg role.arg]
