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
::  cannot construct an action and then use <> because the invites map prints as \{} and not ~
=/  literal=tape  "[%create-event {<cc>} `{<ec>} ~zod {<det>} {<when>} ~ ~ \"utc\"]"
;<  ~  bind:m  (dojo ~zod (weld ":ucal-store &ucal-action " literal))
;<  bol=bowl:spider  bind:m  get-bowl
::  now verify the event's properties
;<  res=vase  bind:m
    %:  validate-event-basic-properties:test-util
      ~zod
      ~zod
      ~zod
      :*
        ec
        cc
        [~zod now.bol now.bol]
        det
        when
        ~
        %yes
        "utc"
      ==
      ~
    ==
~&  [%validation-result-is !<(flag res)]
?>  !<(flag res)
;<  ~  bind:m  end-simple
(pure:m *vase)
