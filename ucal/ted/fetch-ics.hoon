/-  spider
/+  *strandio
=,  strand=strand:spider
=>
|%
--
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url=(unit tape)  !<((unit tape) arg)
?~  url
  %-  (slog leaf+"usage: -fetch-ics <url>" ~)
  (pure:m !>(~))
;<  data=@t  bind:m  (fetch-cord u.url)
%-  (slog leaf+(trip data) ~)
(pure:m !>(~))
