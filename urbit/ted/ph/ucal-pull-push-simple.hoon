/-  spider, *ucal, *ucal-store
/+  *ph-io, ph-util, *ucal-test-util, strandio
=,  strand=strand:spider
^-  thread:spider
|=  args=vase
=/  m  (strand ,vase)
;<  ~  bind:m  start-simple
;<  ~  bind:m  (start-fleet ~[~zod ~nel])
::  create a calendar on ~zod and an event on it
=/  cc=calendar-code  %a
=/  a1=action  [%create-calendar '~zod\'s calendar' `cc]
;<  ~  bind:m  (ucal-poke ~zod a1)
=/  ec=event-code  %b
=/  det=detail  ['working on ucal' `'write some more tests' ~]
=/  when=moment  [%block ~2020.12.4 ~h1]
=/  literal=tape  "[%create-event {<cc>} `{<ec>} ~zod {<det>} {<when>} ~ ~ \"utc\"]"
;<  ~  bind:m  (dojo ~zod (weld ":ucal-store &ucal-action " literal))
::  wait a bit before subscribing
;<  ~  bind:m  (sleep:strandio ~s10)
::  now subscribe to that calendar from ~nel
;<  ~  bind:m  (ucal-pull-hook-poke ~nel [%add ~zod [~zod %a]])
::  nel should now see that same calendar and event
::  wait for stuff to happen
;<  ~  bind:m  (sleep:strandio ~s10)
;<  bol=bowl:spider  bind:m  get-bowl
=/  cal-pax=path  (snoc `path`/~zod/calendars cc)
=/  event-pax=path  ;:(weld /~zod/events/specific ~[cc] ~[ec])
=/  zod-cal=calendar  (scry-ucal-store ~zod bol calendar cal-pax)
=/  nel-cal=calendar  (scry-ucal-store ~nel bol calendar cal-pax)

=/  res=flag  =(zod-cal nel-cal)
~&  >  [%res-is res]
::  if the event is updated, ~nel should see the change

::  if a new event is added on that calendar, ~nel should see it also

::  if an event is deleted, nel should no longer see it

::  if the calendar is deleted, ~nel should not store it anymore
;<  ~  bind:m  end-simple
(pure:m *vase)
