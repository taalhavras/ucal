/-  spider, ucal
/+  *ph-io, ph-util, test-util=ucal-test-util
=,  strand=strand:spider
^-  thread:spider
|=  args=vase
=/  m  (strand ,vase)
;<  ~  bind:m  start-simple
::  start a fake ship, ~zod
;<  ~  bind:m  (raw-ship ~zod ~)
::  now start ucal on zod
;<  ~  bind:m  (start-ucal:test-util ~zod)
::  create a calendar
=/  =action:ucal  [%create-calendar %a 't' ~]
;<  ~  bind:m  (ucal-poke:test-util ~zod action)
::  now verify it has the right properties
;<  res=vase  bind:m  (validate-cal-basic-properties:test-util ~zod ~zod %a 't' ~)
~&  [%validation-result-is !<(flag res)]
?>  !<(flag res)
;<  ~  bind:m  end-simple
(pure:m *vase)
