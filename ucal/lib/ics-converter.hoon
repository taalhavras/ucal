/-  ucal, hora
/+  lhora=hora
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
::  $da-to-datetime: turns an @da into a tape representing an ics date-time
::
++  da-to-datetime
  =<
  |=  [da=@da is-utc=flag]
  ^-  tape
  =/  dat=date  (yore da)
  ;:  weld
      (a-co:co y.dat)
      (pad-to-two-digit m.dat)
      (pad-to-two-digit d.t.dat)
      "T"
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
  =/  is-utc=flag  =(tzid.data.ev "utc")
  =/  [dtstart=tape dtend=tape]  (parse-start-and-end when.data.ev tzid.data.ev)
  =/  location=tape
  ?~  loc.detail.data.ev
    ""
  (trip address.u.loc.detail.data.ev)
  :: TODO there's gotta be a better way to express the optionality of
  :: the RRULE field here.
  %+  weld
    :~  "BEGIN:VEVENT"
        dtstart
        dtend
        (parse-uid ev)
        :: fields from detail
        "SUMMARY:{(trip title.detail.data.ev)}"
        "DESCRIPTION:{(trip (fall desc.detail.data.ev ''))}"
        "LOCATION:{location}"
        :: fields from about
        "ORGANIZER:{(scow %p organizer.about.data.ev)}"
        ::  Created/Last Modified times are always in UTC
        "CREATED:{(da-to-datetime date-created.about.data.ev &)}"
        "LAST-MODIFIED:{(da-to-datetime last-modified.about.data.ev &)}"
    ==
  ?~  era.ev
    ~["END:VEVENT"]
  ~[(parse-era u.era.ev when.data.ev is-utc) "END:VEVENT"]
  |%
  ++  parse-uid
    |=  ev=event:ucal
    ^-  tape
    "UID:{(scow %tas event-code.data.ev)}-{(scow %tas calendar-code.data.ev)}"
  ::
  ++  weekday-to-tape
    |=  w=weekday:hora
    ^-  tape
    ?-  w
      %mon  "MO"
      %tue  "TU"
      %wed  "WE"
      %thu  "TH"
      %fri  "FR"
      %sat  "SA"
      %sun  "SU"
    ==
  ::
  ++  parse-era
    |=  [e=era:hora when=moment:hora is-utc=flag]
    ^-  tape
    =/  type-component=(unit tape)  (era-type-to-component type.e is-utc)
    =/  interval=tape  "INTERVAL={(a-co:co interval.e)}"
    ::  now we just have the rrule left
    =/  recur=tape
    ?:  ?=([%daily *] rrule.e)
      "FREQ=DAILY"
    ?:  ?=([%weekly *] rrule.e)
      =/  days=(list tape)
      (turn ~(tap in days.rrule.e) weekday-to-tape)
      %-  zing
      ^-  (list tape)
      :~  "FREQ=WEEKLY;"
          "BYDAY="
          (zing (join "," days))
      ==
    ?:  ?=([%monthly *] rrule.e)
      %+  weld
        "FREQ=MONTHLY;"
      =/  [start=@da @da]  (moment-to-range:lhora when)
      ?:  ?=([%on *] form.rrule.e)
        =/  day=@ud  d.t:(yore start)
        "BYMONTHDAY={<day>}"
      ?:  ?=([%weekday *] form.rrule.e)
        %+  weld
          ?-  instance.form.rrule.e
            %first  "1"
            %second  "2"
            %third  "3"
            %fourth  "4"
            %last  "-1"
          ==
        (weekday-to-tape (get-weekday:lhora start))
      !!
    ?:  ?=([%yearly *] rrule.e)
      "FREQ=YEARLY"
    !!
    "RRULE:{interval};{recur}"
  ::  convert an era-type to the appropriate until/to rule.
  ::
  ++  era-type-to-component
    |=  [et=era-type:hora is-utc=flag]
    ^-  (unit tape)
    ?:  ?=([%until *] et)
      (some "UNTIL={(da-to-datetime end.et is-utc)}")
    ?:  ?=([%instances *] et)
      (some "COUNT={(a-co:co num.et)}")
    ?:  ?=([%infinite *] et)
      ::  Nothing needs to be specified for %infinite events
      ~
    !!
  ::
  ++  parse-start-and-end
    |=  [m=moment:hora tzid=tape]
    ^-  [tape tape]
    =/  [start=@da end=@da]  (moment-to-range:lhora m)
    =/  is-utc=flag  =(tzid "utc")
    =/  tzstr=tape  ?:(is-utc "" ";TZID={tzid}")
    :-  "DTSTART{tzstr}:{(da-to-datetime start is-utc)}"
    "DTEND{tzstr}:{(da-to-datetime start is-utc)}"
  --
--
