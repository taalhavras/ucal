/-  *sole
/+  *generators
::  An ask generator used to interactively create calendars and events in ucal-store
:-  %ask
|=  *
^-  (sole-result (cask tang))
%+  print  leaf+"What is your favorite color?"
%+  prompt  [%& %prompt "color: "]
|=  t=tape
%+  produce  %tang
?:  =(t "blue")
  :~  leaf+"Oh. Thank you very much."
    leaf+"Right. Off you go then."
  ==
:~  leaf+"Aaaaagh!"
  leaf+"Into the Gorge of Eternal Peril with you!"
==
