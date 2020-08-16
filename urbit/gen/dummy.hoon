/+  hora
:-  %say
|=  *
:-  %noun
=>
|%
++  opt1
  |%
  ++  baz  |=  a=@  [a 2]
  ++  bar  |=  t=tape  [(crip t) t]
  --
++  opt2
  |%
  ++  baz  |=  a=@  [a 4]
  ++  bar  |=  t=tape  [(crip (cuss t)) (cass t)]
  --
+$  t1  $_  ^|  opt1
+$  t2  $_  ^|  opt2
::  now can we produce these cores?
++  make-t
  |=  arg=@
  ::  ^-  t1
  |%
  ++  baz  |=  a=@  [a arg]
  ++  bar  |=  t=tape  ['' ""]
  --
--
%-
  |*  val=t1
  :-
  (baz.val 10)
  (bar.val "I am here")
(make-t 8)
