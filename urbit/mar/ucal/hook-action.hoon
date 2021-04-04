/-  ucal-hook, ucal
/+  ucal-util
|_  act=action:ucal-hook
++  grow
  |%
  ++  noun  act
  --
::
++  grab
  |%
  ++  noun  action:ucal-hook
  ++  json
    |^  |=  jon=json
        ^-  action:ucal-hook
        =,  format
        %.  jon
        %-  of:dejs
        :~  [%query-cals parse-query-cals]
            [%invitation-response parse-invitation-response]
        ==
    ::
    ++  parse-query-cals
      |=  jon=json
      ^-  @p
      ?>  ?=([%o *] jon)
      ((se:dejs:format %p) (~(got by p.jon) 'who'))
    ::
    ++  parse-invitation-response
      |=  jon=json
      ^-  [calendar-code:ucal event-code:ucal rsvp:ucal]
      =,  format
      ?>  ?=([%o *] jon)
      :+  (so:dejs (~(got by p.jon) 'calendar-code'))
        (so:dejs (~(got by p.jon) 'event-code'))
      ((cu:dejs rsvp:ucal so:dejs) (~(got by p.jon) 'status'))
    --
  --
::
++  grad  %noun
--
