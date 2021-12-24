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
::
++  url-prefix  "https://raw.githubusercontent.com/eggert/tz/main/"
++  files
  ^-  wall
  :~  "northamerica"
      "asia"
      "australasia"
      "africa"
      "antarctica"
      "europe"
      "southamerica"
  ==
--
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  url=(unit tape)  !<((unit tape) arg)
;<  our=@p  bind:m  get-our
?~  url
  %-  (slog leaf+(weld "importing all timezones from " url-prefix) ~)
  =/  fcpy=wall  files
  |-
  ^-  form:m
  ::  since each ;< introduces a new $ we need to bind this.
  =*  loop  $
  ?~  fcpy
    (pure:m !>(~))
  %-  (slog leaf+"requesting {i.fcpy}" ~)
  ;<  data=@t  bind:m  (fetch-cord (weld url-prefix i.fcpy))
  ;<  ~  bind:m  (poke [our %timezone-store] (make-import-poke data))
  loop(fcpy t.fcpy)
;<  data=@t  bind:m  (fetch-cord u.url)
;<  ~  bind:m  (poke [our %timezone-store] (make-import-poke data))
(pure:m !>(~))
