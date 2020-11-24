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
=/  a1=action:ucal  [%create-calendar %a 'First Cal' ~]
;<  ~  bind:m  (ucal-poke:test-util ~zod a1)
::  create an event on it
=/  start=@da  ~2020.7.22
=/  end=@da  (add start ~h1)
=/  desc=(unit @t)  `'amazing!'
=/  a2=action:ucal
    [%create-event %a 'First Event' %e1 start [%span ~h1] desc]
;<  ~  bind:m  (ucal-poke:test-util ~zod a2)
::  now verify the event's properties
;<  res=vase  bind:m
    %:  validate-event-basic-properties:test-util
      ~zod
      ~zod
      %a
      %e1
      'First Event'
      start
      end
      desc
    ==
~&  [%validation-result-is !<(flag res)]
?>  !<(flag res)
;<  ~  bind:m  end-simple
(pure:m *vase)
