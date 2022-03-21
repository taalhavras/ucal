/-  *ucal, ucal-sync
|_  act=action:ucal-sync
++  grow
  |%
  ++  noun  act
  --
::
++  grab
  |%
  ++  noun  action:ucal-sync
  ++  json
    =<
    |=  jon=^json
    ^-  action:ucal-sync
    =,  format
    %.  jon
    %-  of:dejs
    :~  [%add convert-add]
        [%remove convert-remove]
        [%adjust convert-adjust]
    ==
    |%
    ++  convert-add
      |=  jon=^json
      ^-  [tape calendar-code @dr]
      =,  format
      ?>  ?=([%o *] jon)
      :+  (sa:dejs (~(got by p.jon) 'url'))
        (so:dejs (~(got by p.jon) 'calendar-code'))
      ((se:dejs %dr) (~(got by p.jon) 'timeout'))
    ::
    ++  convert-remove
      |=  jon=^json
      ^-  calendar-code
      =,  format
      ?>  ?=([%o *] jon)
      (so:dejs (~(got by p.jon) 'calendar-code'))
    ::
    ++  convert-adjust
      |=  jon=^json
      ^-  [calendar-code @dr]
      =,  format
      ?>  ?=([%o *] jon)
      :-  (so:dejs (~(got by p.jon) 'calendar-code'))
      ((se:dejs %dr) (~(got by p.jon) 'new-timeout'))
    --
  --
::
++  grad  %noun
--
