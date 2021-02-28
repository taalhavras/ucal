/+  *server, default-agent
::
|%
+$  card  card:agent:gall
--
^-  agent:gall
|_  bol=bowl:gall
+*  this       .
    calendar-core  +>
    cc         ~(. calendar-core bol)
    def        ~(. (default-agent this %|) bol)
::
++  on-init
  ^-  (quip card _this)
  =/  launcha  [%launch-action !>([%add %calendar [[%basic 'calendar' '/~calendar/img/tile.png' '/~calendar'] %.y]])]
  =/  filea  [%file-server-action !>([%serve-dir /'~calendar' /app/calendar %.n %.y])]
  :_  this
  :~  [%pass /srv %agent [our.bol %file-server] %poke filea]
      [%pass /calendar %agent [our.bol %launch] %poke launcha]
      ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?:  ?=([%http-response *] path)
    `this
  ?.  =(/ path)
    (on-watch:def path)
  [[%give %fact ~ %json !>(*json)]~ this]
::
++  on-agent  on-agent:def
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=(%bound +<.sign-arvo)
    (on-arvo:def wire sign-arvo)
  [~ this]
::
++  on-poke  on-poke:def
++  on-save  on-save:def
++  on-load  on-load:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-fail   on-fail:def
--
