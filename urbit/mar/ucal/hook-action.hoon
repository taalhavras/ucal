/-  ucal-hook, ucal-store
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
            [%proxy-poke parse-proxy-poke]
            [%invitation-response parse-invitation-response]
        ==
    ::
    ++  parse-query-cals
      |=  jon=json
      ^-  @p
      ?>  ?=([%o *] jon)
      ((se:dejs:format %p) (~(got by p.jon) 'who'))
    ::
    ++  parse-proxy-poke
      |=  jon=json
      ^-  [@p action:ucal-store]
      ?>  ?=([%o *] jon)
      :-  ((se:dejs:format %p) (~(got by p.jon) 'target'))
      (ucal-action-from-json:ucal-util (~(got by p.jon) 'store-action'))
    ::
    ++  parse-invitation-response
      |=  jon=json
      ^-  [calendar-code:ucal event-code:ucal rsvp:ucal-store]
      =,  format
      ?>  ?=([%o *] jon)
      :+  (so:dejs (~(got by p.jon) 'calendar-code'))
        (so:dejs (~(got by p.jon) 'event-code'))
      ((cu:dejs rsvp:ucal-store so:dejs) (~(got by p.jon) 'status'))
    --
  --
::
++  grad  %noun
--
