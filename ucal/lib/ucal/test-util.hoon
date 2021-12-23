/-  spider, ucal, ucal-store, hora, pull-hook
/+  *ph-io, ph-util
=,  strand=strand:spider
|%
::  $start-fleet: spin up the specified ships and start
::  ucal-store and ucal-{pull,push}-hook on the specified ships.
::
++  start-fleet
  |=  ships=(list @p)
  =/  m  (strand ,~)
  ^-  form:m
  ?~  ships
    (pure:m ~)
  ;<  ~  bind:m  (raw-ship i.ships ~)
  ;<  ~  bind:m  (start-ucal-store i.ships)
  ;<  ~  bind:m  (start-ucal-pull-hook i.ships)
  ;<  ~  bind:m  (start-ucal-push-hook i.ships)
  ::  TODO figure out how to make this use $ and not explicit recursion
  ;<  ~  bind:m  (start-fleet t.ships)
  (pure:m ~)
::
++  start-ucal-store
  |=  on=@p
  =/  m  (strand ,~)
  ^-  form:m
  ;<  ~  bind:m  (dojo on "|start %ucal-store")
  (wait-for-output on "activated app home/ucal-store")
::
++  start-ucal-pull-hook
  |=  on=@p
  =/  m  (strand ,~)
  ^-  form:m
  ;<  ~  bind:m  (dojo on "|start %ucal-pull-hook")
  (wait-for-output on "activated app home/ucal-pull-hook")
  ::
++  start-ucal-push-hook
  |=  on=@p
  =/  m  (strand ,~)
  ^-  form:m
  ;<  ~  bind:m  (dojo on "|start %ucal-push-hook")
  (wait-for-output on "activated app home/ucal-push-hook")
::
::  TODO factor these poking functions into a common helper?
++  ucal-pull-hook-poke
  |=  [on=@p =action:pull-hook]
  =/  m  (strand ,~)
  ^-  form:m
  ;<  ~  bind:m  (dojo on ":ucal-pull-hook &pull-hook-action {<action>}")
  ;<  ~  bind:m  (wait-for-output on ">=")
  (pure:m ~)
::
::  TODO specialize to avoid the map problem?
++  ucal-poke
  |=  [on=@p =action:ucal-store]
  =/  m  (strand ,~)
  ^-  form:m
  =/  t=tape  ":ucal-store &ucal-action {<action>}"
  ;<  ~  bind:m  (dojo on t)
  ;<  ~  bind:m  (wait-for-output on ">=")
  (pure:m ~)
::
::  scry into ucal-store on a specific aqua ship - takes the same
::  parameters that you might pass to .^ in the dojo.
::  so you would just pass /calendars/a if you wanted to look
::  at /gy/=ucal=/calendars/a on the specified ship.
::
::  TODO  currently this assumes that all ucal scrys are %gy
::  which is currently true but maybe this'll change? note that
::  %gx scrys require two trailing %nouns while %gy needs one
++  scry-ucal-store
  |*  [into=@p bol=bowl:spider mol=mold pax=path]
  ^-  mol
  ::  /j/~zod/rift/now/target-ship becomes the below
  ::  /i/(scot %p her)/j/(scot %p her)/rift/(scot %da now.bowl)/(scot %p who)/noun
  =/  prefix=path  ~[%i (scot %p into) %gy (scot %p into) %ucal-store (scot %da now.bol)]
  =/  new-path=path  (weld prefix (snoc `path`pax %noun))
  =/  res  (scry-aqua:ph-util * our.bol now.bol new-path)
  %-  need
  ;;((unit mol) res)
::
++  validate-cal
  |=  [on=@p target=@p code=calendar-code:ucal v=$-(calendar:ucal flag)]
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  >  [%validating-cal on code]
  ;<  bol=bowl:spider  bind:m  get-bowl
  =/  =path  ~[(scot %p target) %calendars code]
  ~&  >  [%path path]
  =/  cal=calendar:ucal
      (scry-ucal-store on bol calendar:ucal path)
  ~&  >  [%got-cal cal]
  (pure:m !>((v cal)))
::
++  validate-event
  |=  [on=@p target=@p =calendar-code:ucal =event-code:ucal v=$-(event:ucal flag)]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  bol=bowl:spider  bind:m  get-bowl
  =/  ev=event:ucal
      (scry-ucal-store on bol event:ucal ~[(scot %p target) %events %specific calendar-code event-code])
  (pure:m !>((v ev)))
::
++  cal-basic-properties-match
  |=  [cal=calendar:ucal owner=@p code=calendar-code:ucal title=@t]
  ^-  flag
  ?&
    =(owner.cal owner)
    =(calendar-code.cal code)
    =(title.cal title)
  ==
::
++  validate-cal-basic-properties
  |=  [on=@p target=@p owner=@p code=calendar-code:ucal title=@t]
  =/  validator
      (bake (curr cal-basic-properties-match [owner code title]) calendar:ucal)
  (validate-cal on target code validator)
::
++  event-basic-properties-match
  =>
  |%
  ++  epsilon  ^-  @dr  ~s1
  ++  das-equal
    |=  [a=@da b=@da]
    ^-  flag
    ?:  (gth a b)
      (lte (sub a b) epsilon)
    (lte (sub b a) epsilon)
  --
  |=  [=event:ucal owner=@p data=event-data:ucal era=(unit era:hora)]
  ^-  flag
  ?&
    ::  don't check the event's modification time or creation time since
    ::  they won't be the same as whatever time is used to verify. instead, check
    ::  that they're within 1 second.
    ?&
      =(event-code.data.event event-code.data)
      =(calendar-code.data.event calendar-code.data)
      =(detail.data.event detail.data)
      =(when.data.event when.data)
      =(invites.data.event invites.data)
      =(rsvp.data.event rsvp.data)
      =(tzid.data.event tzid.data)
      =(organizer.about.data.event organizer.about.data)
      (das-equal date-created.about.data.event date-created.about.data)
      (das-equal last-modified.about.data.event last-modified.about.data)
    ==
    =(era.event era)
  ==
::
++  validate-event-basic-properties
  |=  [on=@p target=@p owner=@p =event-data:ucal era=(unit era:hora)]
  =/  validator
      %+  bake
        %+  curr
          event-basic-properties-match
        [owner event-data era]
      event:ucal
  (validate-event on target calendar-code.event-data event-code.event-data validator)
--
