/-  spider, ucal
/+  *ph-io, ph-util
=,  strand=strand:spider
=<
^-  thread:spider
|=  args=vase
=/  m  (strand ,vase)
;<  ~  bind:m  start-simple
::  start two fake ships, ~zod and ~nel
;<  ~  bind:m  (raw-ship ~zod ~)
::  ;<  ~  bind:m  (raw-ship ~nel ~)
::  import ucal for future dojo-ing
::  ;<  ~  bind:m  (dojo ~zod dojo-ucal-import)
::  ;<  ~  bind:m  (dojo ~nel dojo-ucal-import)
::  now start ucal on zod
;<  ~  bind:m  (start-ucal ~zod)
::  create a calendar
=/  a1=action:ucal  [%create-calendar %a 'First Cal' ~]
;<  ~  bind:m  (ucal-poke ~zod a1)
::  now verify it has the right properties
;<  res=vase  bind:m  (validate-cal ~zod `calendar-code:ucal`%a 'First Cal' ~)
~&  [%validation-result-is !<(flag res)]
;<  ~  bind:m  end-simple
(pure:m *vase)
::  util core
|%
++  dojo-ucal-import  "/-  *ucal"
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
++  test-types
  |.
  =/  m  (strand ,vase)
  ^-  form:m
  (pure:m *vase)
::
++  validate-cal
  |=  [on=@p code=calendar-code:ucal title=@t tz=(unit timezone:ucal)]
  =/  m  (strand ,vase)
  ^-  form:m
  ~&  >  [%validating-cal on code]
  ;<  bol=bowl:spider  bind:m  get-bowl
  ::  /j/~zod/rift/now/target-ship becomes the below
  ::  /i/(scot %p her)/j/(scot %p her)/rift/(scot %da now.bowl)/(scot %p who)/noun
  ::  in our case, the path is /gy/~zod/ucal/now/calendars/a
  ::  this then becomes /i/~zod/gy/~zod/ucal/now/calendars/a/noun
  =/  pax=path  [%i (scot %p on) %gy (scot %p on) %ucal (scot %da now.bol) %calendars code %noun ~]
  ~&  >  [%scrying-on pax]
  ::  scry-aqua produces unit
  =/  cal  %-  need
      ;;((unit calendar:ucal) (scry-aqua:ph-util noun on now.bol pax))
  ~&  >  [%got-cal cal]
  %-  pure:m
  !>
  ?&
    =(calendar-code.cal code)
    =(title.cal title)
    =(timezone.cal (fall tz 'utc'))
  ==
--
