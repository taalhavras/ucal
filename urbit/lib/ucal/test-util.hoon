/-  spider, ucal
/+  *ph-io, ph-util
=,  strand=strand:spider
|%
::
++  start-ucal
  |=  on=@p
  =/  m  (strand ,~)
  ^-  form:m
  ;<  ~  bind:m  (dojo on "|start %ucal")
  ::  activated app home/ucal
  (wait-for-output on "activated app home/ucal")
::
++  ucal-poke
  |=  [on=@p =action:ucal]
  =/  m  (strand ,~)
  ^-  form:m
  =/  t=tape  (weld ":ucal &ucal-action " <action>)
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
  =/  prefix=path  ~[%i c-on %gy c-on %ucal (scot %da now.bol)]
  =/  new-path=path  (weld prefix (snoc `path`pax %noun))
  %-  need
  ;;((unit mol) (scry-aqua:ph-util noun on now.bol new-path))
::
++  validate-cal
  |=  [on=@p code=calendar-code:ucal v=$-(calendar:ucal flag)]
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  >  [%validating-cal on code]
  ;<  bol=bowl:spider  bind:m  get-bowl
  =/  cal=calendar:ucal
      (scry-ucal on bol calendar:ucal ~[%calendars code])
  ~&  >  [%got-cal cal]
  (pure:m !>((v cal)))
::
++  validate-event
  |=  [on=@p =calendar-code:ucal =event-code:ucal v=$-(event:ucal flag)]
  =/  m  (strand ,vase)
  ^-  form:m
  ;<  bol=bowl:spider  bind:m  get-bowl
  =/  ev=event:ucal
      (scry-ucal on bol event:ucal ~[%events calendar-code event-code])
  (pure:m !>((v ev)))
::
++  cal-basic-properties-match
  |=  [cal=calendar:ucal code=calendar-code:ucal title=@t tz=(unit timezone:ucal)]
  ^-  flag
  ?&
    =(calendar-code.cal code)
    =(title.cal title)
    =(timezone.cal (fall tz 'utc'))
  ==
::
++  validate-cal-basic-properties
  |=  [on=@p code=calendar-code:ucal title=@t tz=(unit timezone:ucal)]
  =/  validator
      (bake (curr cal-basic-properties-match [code title tz]) calendar:ucal)
  (validate-cal on code validator)
--
