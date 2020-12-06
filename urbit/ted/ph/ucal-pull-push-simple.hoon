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
;<  ~  bind:m  (sleep:strandio ~s4)
::  now subscribe to that calendar from ~nel
;<  ~  bind:m  (ucal-pull-hook-poke ~nel [%add ~zod [~zod %a]])
::  nel should now see that same calendar and event
::  wait for stuff to happen
;<  ~  bind:m  (sleep:strandio ~s4)
;<  bol=bowl:spider  bind:m  get-bowl
=/  cal-pax=path  (snoc `path`/~zod/calendars cc)
=/  event-pax=path  ;:(weld /~zod/events/specific ~[cc] ~[ec])
=/  zod-cal=calendar  (scry-ucal-store ~zod bol calendar cal-pax)
=/  nel-cal=calendar  (scry-ucal-store ~nel bol calendar cal-pax)
=/  res=flag  =(zod-cal nel-cal)
~&  >  [%cals-equal res]
?>  res
=/  zod-event=event  (scry-ucal-store ~zod bol event event-pax)
=/  nel-event=event  (scry-ucal-store ~nel bol event event-pax)
=/  res=flag  =(zod-event nel-event)
~&  >  [%events-equal res]
?>  res
::  if the event is updated, ~nel should see the change
=/  new-moment=moment  [%block ~2020.12.5 ~h1]
=/  new-title=cord  'working on martian timekeeping'
=/  ep=event-patch  [cc ec `new-title ~ ~ ~ `new-moment ~ ~]
;<  ~  bind:m  (ucal-poke ~zod `action`[%update-event ep])
;<  ~  bind:m  (sleep:strandio ~s2)
;<  bol=bowl:spider  bind:m  get-bowl
=/  zod-event=event  (scry-ucal-store ~zod bol event event-pax)
=/  nel-event=event  (scry-ucal-store ~nel bol event event-pax)
=/  res=flag
    ?&
      =(zod-event nel-event)
      =(when.data.zod-event new-moment)
      =(title.detail.data.zod-event new-title)
    ==
~&  >  [%events-equal-after-change res]
?>  res
::  if a new event is added on that calendar, ~nel should see it also
=/  ec-2=event-code  %c
=/  det-2=detail  ['Movie night!' ~ ~]
=/  when-2=moment  [%block ~2020.12.8 ~h3]
=/  literal-2=tape  "[%create-event {<cc>} `{<ec-2>} ~zod {<det-2>} {<when-2>} ~ ~ \"utc\"]"
;<  ~  bind:m  (dojo ~zod (weld ":ucal-store &ucal-action " literal-2))
;<  ~  bind:m  (sleep:strandio ~s2)
=/  event-pax-2=path  ;:(weld /~zod/events/specific ~[cc] ~[ec-2])
;<  bol=bowl:spider  bind:m  get-bowl
=/  zod-event-2=event  (scry-ucal-store ~zod bol event event-pax-2)
=/  nel-event-2=event  (scry-ucal-store ~nel bol event event-pax-2)
=/  res=flag  =(zod-event-2 nel-event-2)
~&  >  [%second-event-equal res]
?>  res
::  if an event is deleted, nel should no longer see it
::  if the calendar is deleted, ~nel should not store it anymore
;<  ~  bind:m  end-simple
(pure:m *vase)
