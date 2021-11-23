/-  spider, ucal-store
/+  *strandio
=,  strand=strand:spider
=>
|%
++  make-import-poke
  |=  data=@t
  ^-  cage
  :-  %ucal-action
  !>  ^-  action:ucal-store
  [%import-from-ics %data data]
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
;<  our=@p  bind:m  get-our
;<  ~  bind:m  (poke [our %ucal-store] (make-import-poke data))
(pure:m !>(~))
