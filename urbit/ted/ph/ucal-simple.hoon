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
;<  ~  bind:m  (start-ucal-store:test-util ~zod)
::  create a calendar
=/  cal-name=cord  'test cal'
=/  cc=calendar-code  %a
=/  =action  [%create-calendar cal-name `cc]
;<  ~  bind:m  (ucal-poke:test-util ~zod action)
;<  bol=bowl:spider  bind:m  get-bowl
=/  cal  (scry-ucal:test-util ~zod bol calendar (snoc `path`/~zod/calendars cc))
~&  >  [%res-is cal]
::  now verify it has the right properties
::  ;<  res=vase  bind:m  (validate-cal-basic-properties:test-util ~zod ~zod ~zod cc cal-name)
::  ~&  [%validation-result-is !<(flag res)]
::  ?>  !<(flag res)
;<  ~  bind:m  end-simple
(pure:m *vase)
