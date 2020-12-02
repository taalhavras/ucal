/-  spider, *ucal, *ucal-store
/+  *ph-io, ph-util, test-util=ucal-test-util
=,  strand=strand:spider
^-  thread:spider
|=  args=vase
=/  m  (strand ,vase)
;<  ~  bind:m  start-simple
::  start a fake ship, ~zod
;<  ~  bind:m  (raw-ship ~zod ~)
::  now start ucal on zod
;<  ~  bind:m  (dojo ~zod "|start %ucal-store")
;<  ~  bind:m  (wait-for-output ~zod "activated app home/ucal-store")
::  create a calendar
=/  cal-name=cord  'test cal'
=/  cc=calendar-code  %a
=/  =action  [%create-calendar cal-name `cc]
;<  ~  bind:m  (dojo ~zod (weld ":ucal-store &ucal-action " <action>))
;<  ~  bind:m  (wait-for-output ~zod ">=")
;<  bol=bowl:spider  bind:m  get-bowl
~&  >  [%bol-is bol]
=/  pax=path  ~[%i (scot %p ~zod) %gy (scot %p ~zod) %ucal-store (scot %da now.bol) (scot %p ~zod) %calendars cc %noun]
~&  >  [%path-is pax]
=/  res  (scry-aqua:ph-util * ~zod now.bol pax)
::  ~&  >  [%res-is res]
::  now verify it has the right properties
::  ;<  res=vase  bind:m  (validate-cal-basic-properties:test-util ~zod ~zod ~zod cc cal-name)
::  ~&  [%validation-result-is !<(flag res)]
::  ?>  !<(flag res)
;<  ~  bind:m  end-simple
(pure:m *vase)
