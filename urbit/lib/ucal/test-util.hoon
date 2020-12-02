/-  spider, ucal, ucal-store, hora
/+  *ph-io, ph-util
=,  strand=strand:spider
|%
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
++  ucal-poke
  |=  [on=@p =action:ucal-store]
  =/  m  (strand ,~)
  ^-  form:m
  =/  t=tape  (weld ":ucal-store &ucal-action " <action>)
  ~&  >  [%poking-ucal on action]
  ;<  ~  bind:m  (dojo on t)
  ;<  ~  bind:m  (wait-for-output on ">=")
  (pure:m ~)
::
::  scry into ucal on a specific aqua ship - takes the same
::  parameters that you might pass to .^ in the dojo.
::  so you would just pass /calendars/a if you wanted to look
::  at /gy/=ucal=/calendars/a on the specified ship.
::
::  TODO  currently this assumes that all ucal scrys are %gy
::  which is currently true but maybe this'll change? note that
::  %gx scrys require two trailing %nouns while %gy needs one
++  scry-ucal
  |*  [on=@p bol=bowl:spider mol=mold pax=path]
  ^-  mol
  ::  /j/~zod/rift/now/target-ship becomes the below
  ::  /i/(scot %p her)/j/(scot %p her)/rift/(scot %da now.bowl)/(scot %p who)/noun
  =/  c-on=cord  (scot %p on)
  =/  prefix=path  ~[%i c-on %gy c-on %ucal-store (scot %da now.bol)]
  ::  =/  new-path=path  (weld prefix pax)
  =/  new-path=path  (weld prefix (snoc `path`pax %noun))
  ~&  >  [%path-is new-path]
  =/  res  (scry-aqua:ph-util * on now.bol new-path)
  ~&  >  [%res-is res]
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
      (scry-ucal on bol calendar:ucal path)
  ~&  >  [%got-cal cal]
  (pure:m !>((v cal)))
::
++  validate-event
  |=  [on=@p target=@p =calendar-code:ucal =event-code:ucal v=$-(event:ucal flag)]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  bol=bowl:spider  bind:m  get-bowl
  =/  ev=event:ucal
      (scry-ucal on bol event:ucal ~[(scot %p target) %events %specific calendar-code event-code])
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
  |=  [=event:ucal owner=@p =event-data:ucal era=(unit era:hora)]
  ^-  flag
  ?&
    =(data.event event-data)
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
