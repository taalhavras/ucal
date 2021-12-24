/-  spider, timezone-store
/+  *strandio
=,  strand=strand:spider
=>
|%
++  make-import-poke
  |=  data=@t
  ^-  cage
  :-  %timezone-store-action
  !>  ^-  action:timezone-store
  [%import-blob data]
--
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url=(unit tape)  !<((unit tape) arg)
?~  url
  %-  (slog leaf+"usage: -fetch-timezone <url>" ~)
  (pure:m !>(~))
;<  data=@t  bind:m  (fetch-cord u.url)
;<  our=@p  bind:m  get-our
;<  ~  bind:m  (poke [our %timezone-store] (make-import-poke data))
(pure:m !>(~))
