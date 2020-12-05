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
=/  cc=calendar-code  %a
=/  a1=action  [%create-calendar 'First Cal' `cc]
;<  ~  bind:m  (ucal-poke:test-util ~zod a1)
::  create an event on it
=/  det=detail  ['first event!' `'a test event.' ~]
=/  when=moment  [%block ~2020.12.4 ~h1]
=/  ec=event-code  %b
=/  a2=action  [%create-event cc `ec ~zod det when ~ ~ "utc"]
::  ;<  ~  bind:m  (ucal-poke:test-util ~zod a2)
~&  >  [%str-is <a2>]
::  ;<  ~  bind:m  (dojo ~zod ":ucal-store &ucal-action {<a2>}")
;<  ~  bind:m  (dojo ~zod ":ucal-store|create-event {<cc>} 'first event!' [%block ~2020.12.4 ~h1], =event-code `{<ec>}")
;<  bol=bowl:spider  bind:m  get-bowl
=/  ev=event  (scry-ucal:test-util ~zod bol event /~zod/events/specific/a/b)
~&  >  [%ev-is ev]
::  now verify the event's properties
::  ;<  res=vase  bind:m
::      %:  validate-event-basic-properties:test-util
::        ~zod
::        ~zod
::        ~zod
::        %a
::        %b
::        'First Event'
::        start
::        end
::        desc
::      ==
::  ~&  [%validation-result-is !<(flag res)]
::  ?>  !<(flag res)
;<  ~  bind:m  end-simple
(pure:m *vase)
