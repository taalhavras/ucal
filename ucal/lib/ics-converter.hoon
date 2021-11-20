/-  ucal, hora
::  Core for converting ucal types into entries in .ics files.
::
|%
::  +fold-lines: "folds" lines to the desired length
::
::    lines in an ICS file cannot be more than 75 octets,
::    not including line breaks. When we find a line more
::    than 75 octets long we must split or "fold" it into
::    two lines. To signify that a fold has occurred we
::    write a CRLF to the end of the first line and a whitespace
::    to the start of the second.
::
::
++  fold-lines
  =<
  |=  lines=wall
  ^-  wall
  (zing (turn lines fully-fold))
  |%
  ++  octet-limit  75
  ++  clrf  '\09'
  ++  space  ' '
  ::  Determine if a single line should be folded. returns tuple of the
  ::  folded lines if the input needs to be folded. Note that while the
  ::  first line in the tuple is folded, the second line may also need
  ::  to be folded.
  ::
  ++  fold-single-line
    |=  line=tape
    ^-  (unit [tape tape])
    =/  n  (lent line)
    ?:  (lte n octet-limit)
      ~
    ::  line is more than 75 characters. we choose to arbitrarily
    ::  split at 2 less than the octet limit.
    ::
    =/  split-idx=@ud  (sub octet-limit 2)
    =/  line-1=tape  (snoc (scag split-idx line) clrf)
    =/  line-2=tape  [space (slag split-idx line)]
    (some [line-1 line-2])
  ::
  ++  fully-fold
    |=  line=tape
    ^-  (list tape)
    =|  acc=(list tape)
    |-
    =/  folded=(unit [tape tape])  (fold-single-line line)
    ?~  folded
      (flop [line acc])
    $(acc [-.u.folded acc], line +.u.folded)
  --
::  $da-to-datetime: parses an @da into a tape representing an ics date-time
::
++  da-to-datetime
  =<
  |=  [da=@da is-utc=flag]
  ^-  tape
  =/  dat=date  (yore da)
  ;:  weld
      "{<y.dat>}{(pad-to-two-digit m.dat)}{(pad-to-two-digit d.t.dat)}T"
      (pad-to-two-digit h.t.dat)
      (pad-to-two-digit m.t.dat)
      (pad-to-two-digit s.t.dat)
      ?:(is-utc "Z" "")
  ==
  |%
  ++  pad-to-two-digit
    |=  dig=@ud
    ^-  tape
    ?:((lth dig 10) "0{<dig>}" "{<dig>}")
  --
::  +convert-event: turn a single ucal:event into VEVENT lines.
::
++  convert-event
  =<
  |=  ev=event:ucal
  ^-  wall
  !!
  |%
  ++  era-to-rrule
    |=  e=era:hora
    ^-  tape
    !!
  ::  parse an era-type to the appropriate until/to rule.
  ::
  ++  era-type-to-component
    |=  [et=era-type:hora is-utc=flag]
    ^-  (unit tape)
    ?:  ?=([%until *] et)
      (some "UNTIL={(da-to-datetime end.et is-utc)}")
    ?:  ?=([%instances *] et)
      (some "COUNT={<num.et>}")
    ?:  ?=([%infinite *] et)
      ::  Nothing needs to be specified for %infinite events
      ~
    !!
  --
--
