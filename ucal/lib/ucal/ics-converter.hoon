/-  ucal, hora, iana=iana-components
/+  lhora=hora, liana=iana-util
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
::  +pad-to-two-digit: helper to pad an @ud to two digits in tape form
::
++  pad-to-two-digit
  |=  dig=@ud
  ^-  tape
  ?>  (lth dig 100)
  ?:((lth dig 10) "0{<dig>}" "{<dig>}")
::  +da-to-datetime: turns an @da into a tape representing an ics date-time
::
++  da-to-datetime
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
::  +event-to-vevent: turn a single ucal:event into VEVENT lines.
::
++  event-to-vevent
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
    "DTEND{tzstr}:{(da-to-datetime end is-utc)}"
  --
::  Prefix/Suffix for ics files - all ics files must be wrapped in a
::  VCALENDAR component (even single events).
::
++  ics-prefix  `wall`["BEGIN:VCALENDAR" "VERSION:2.0" ~]
++  ics-suffix  `wall`["END:VCALENDAR\0a" ~]
::  +convert-calendar-and-event: make full ICS file from calendar + events
::
++  convert-calendar-and-events
  =<
  |=  [cal=calendar:ucal evs=(list event:ucal)]
  ^-  wall
  %-  fold-lines
  ;:  weld
    ics-prefix
    `wall`~["PRODID:{(make-prodid cal)}"]
    `wall`(zing (turn evs event-to-vevent))
    ics-suffix
  ==
  |%
  ::  +make-prodid: make a "PRODID" - a globally unique ID
  ::
  ++  make-prodid
    |=  cal=calendar:ucal
    ^-  tape
    ::  since these must be globally unique we combine the
    ::  owner and calendar-code as these must be globally
    ::  unique within ucal.
    ;:(weld (scow %p owner.cal) "/" (trip calendar-code.cal))
  --
::  +convert-event: convert a single event into an ICS file
::
++  convert-event
  |=  ev=event:ucal
  ^-  wall
  %-  fold-lines
  ;:  weld
    ics-prefix
    `wall`~["PRODID:{(trip event-code.data.ev)}"]
    (event-to-vevent ev)
    ics-suffix
  ==
::  +convert-events: convert a list of events into an ICS file
::
++  convert-events
  |=  evs=(list event:ucal)
  ^-  wall
  %-  fold-lines
  ;:  weld
    ics-prefix
    ::  TODO there is probably a better way of generating a PRODID
    ::  here since it's supposed to be globally unique.
    ~["PRODID:{(trip event-code.data:(snag 0 evs))}"]
    `wall`(zing (turn evs event-to-vevent))
    ics-suffix
  ==
::  +convert-zone: converts a timezone to VTIMEZONE lines
::
::
::    Since this has to scry into the timezone-store we must pass
::    the current @p and @da. An alternative API would be for the
::    caller to do all scries beforehand and just pass the relevant
::    into in but IMO that's kind of a waste.
::
++  convert-zone
  =<
  |=  [[us=@p now=@da] zone-name=tape]
  ^-  wall
  =/  =zone:iana
  .^  zone:iana
    %gx
    (scot %p us)
    %timezone-store
    (scot %da now)
    %zones
    `@ta`(crip zone-name)
    %noun
    ~
  ==
  %-  fold-lines
  ;:  weld
      `wall`~["BEGIN:VTIMEZONE" "TZID:{(trip name.zone)}"]
      `wall`(zing (turn entries.zone (cury zone-entry-to-lines [us now])))
      `wall`~["END:VTIMEZONE"]
  ==
  |%
  ++  zone-entry-to-lines
    |=  [[us=@p now=@da] entry=zone-entry:iana]
    ^-  wall
    ?:  ?=([%nothing *] rules.entry)
      (build-nothing entry)
    ?:  ?=([%delta *] rules.entry)
      (build-delta entry delta.rules.entry)
    ?:  ?=([%rule *] rules.entry)
      =/  tzr=tz-rule:iana
      .^  tz-rule:iana
        %gx
        (scot %p us)
        %timezone-store
        (scot %da now)
        %rules
        name.rules.entry
        %noun
        ~
      ==
      (build-rule-based entry tzr)
    !!
  ::
  ++  build-nothing
    |=  entry=zone-entry:iana
    ^-  wall
    (build-delta-or-nothing-helper entry stdoff.entry)
  ::
  ++  build-delta
    |=  [entry=zone-entry:iana d=delta:iana]
    ^-  wall
    =/  new-delta=delta:iana  (add-deltas:liana d stdoff.entry)
    (build-delta-or-nothing-helper entry new-delta)
  ::  Common logic between building %nothing and %delta zones
  ++  build-delta-or-nothing-helper
    |=  [entry=zone-entry:iana =delta:iana]
    ^-  wall
    =/  offset=tape  (build-offset delta)
    :: Since zones can sometimes not have a `from` (unlike rules)
    :: we will set a lower bound of ~1111.1.1 here. It's lower than
    :: anything in the IANA DB ATM so I expect it to be a fine lower
    :: bound.
    =/  st=seasoned-time:iana  from.entry(when (max when.from.entry ~1111.1.1))
    :~  standard-prefix
        (build-dtstart st)
        "TZOFFSETTO:{offset}"
        "TZOFFSETFROM:{offset}"
        standard-suffix
    ==
  ::
  ++  build-rule-based
    =<
    |=  [entry=zone-entry:iana rule=tz-rule:iana]
    ^-  wall
    ::  Logic here is as follows:
    ::  We must establish a mapping between the `standard` and `saving`
    ::  rule entries so we can properly calculate TZOFFSETFROM for
    ::  individual STANDARD/DAYLIGHT components.
    ::
    ::  Once we have this mapping we can go through each `standard` and
    ::  `saving` component. For each we will generate a STANDARD/DAYLIGHT
    ::  component _for each rule it maps to_ - i.e. if a `standard` rule
    ::  was in effect for 3 different `saving` rules we'd need `3`
    ::  different STANDARD components, each with a different
    ::  TZOFFSETFROM.
    ::
    ?:  |(=(standard.rule ~) =(saving.rule ~))
      ::  We should always have at least one of each kind of rule.
      ::  Logically any case where we would only have i.e. `standard`
      ::  rules could just be represented as multiple different zone
      ::  entries instead. If this ever does happen it's not too hard
      ::  to handle - we'll just need to only generate components based
      ::  on the one list and we can just set TZOFFSETFROM to whatever
      ::  the earlier rule-entry had.
      !!
    =/  [standard=rule-mapping saving=rule-mapping]
    (pair-rules [standard saving]:rule)
    %-  zing
    %+  weld
      %+  turn
        ~(tap by standard)
      (cury (cury generate-lines |) entry)
    %+  turn
      ~(tap by saving)
    (cury (cury generate-lines &) entry)
    |%
    +$  rule-mapping  (jar rule-entry:iana rule-entry:iana)
    ::
    ++  pair-rules
      |=  [standard=(list rule-entry:iana) saving=(list rule-entry:iana)]
      ^-  [rule-mapping rule-mapping]
      :-  (determine-mappings standard saving)
      (determine-mappings saving standard)
    ::
    ++  determine-mappings
      |=  [for=(list rule-entry:iana) others=(list rule-entry:iana)]
      ^-  rule-mapping
      %+  reel
        for
      |=  [cur=rule-entry:iana acc=rule-mapping]
      ^-  rule-mapping
      (~(put by acc) cur (determine-single-mapping cur others))
    ::  +determine-single-mapping: produce list of entries from `others`
    ::  that are in the same year(s) as `for.
    ::
    ++  determine-single-mapping
      |=  [for=rule-entry:iana others=(list rule-entry:iana)]
      ^-  (list rule-entry:iana)
      %+  skim
        others
      |=  cur=rule-entry:iana
      ^-  flag
      ::  see https://stackoverflow.com/questions/3269434 for an
      ::  explanation of this check. The defaults chosen for `to` are
      ::  just so that the condition returns true in those cases.
      ?&  (lte from.for (fall to.cur from.for))
          (lte from.cur (fall to.for from.cur))
      ==
    ::  +generate-lines: produce VTIMEZONE lines from a rule and the
    ::  corresponding rules it maps to.
    ::
    ++  generate-lines
      |=  [saving=flag entry=zone-entry:iana for=rule-entry:iana mapped=(list rule-entry:iana)]
      ^-  wall
      ::  We might not have any mappings here due to the IANA database
      ::  being incomplete. This is generally only true for old dates
      ::  (i.e. ~1950s) so we don't assert this here.
      %-  zing
      (turn mapped (curr (cury generate-single-component for) [saving entry]))
    ::
    ++  generate-single-component
      |=  [for=rule-entry:iana other=rule-entry:iana saving=flag entry=zone-entry:iana]
      ^-  wall
      =/  start=seasoned-time:iana
      %:  build-seasoned-time:liana
          :: FIXME improve this as per the comment
          :: We base the start of this particular component on the
          :: start of the mapped-to rule. Ideally this would instead be
          :: from.for for the earliest instance of this component and
          :: from.other for all subsequent rules. However this'll only
          :: cause issues for really early rules so it doesn't super
          :: matter.
          from.other
          `in.for
          `on.for
          `offset.at.for
          `flavor.at.for
      ==
      ::  We need an RRULE section here as well - derive it from `from`
      :~  ?:(saving daylight-prefix standard-prefix)
          (build-dtstart start)
          "TZOFFSETTO:{(build-offset (add-deltas:liana stdoff.entry save.for))}"
          "TZOFFSETFROM:{(build-offset (add-deltas:liana stdoff.entry save.other))}"
          (build-rrule-line for other)
          ?:(saving daylight-suffix standard-suffix)
      ==
    ::
    ++  build-rrule-line
      |=  [for=rule-entry:iana other=rule-entry:iana]
      ^-  tape
      =/  day-sections=(list tape)
      ?@  on.for
        ~["BYMONTHDAY={<on.for>};"]
      =/  payload  (tail on.for)
      =/  wday=tape  (weekday-to-tape (head on.for))
      ::  Construct rule sections that determine which day of the month
      ::  the rule comes into effect.
      =/  pos=tape
      ?:  ?=([%on *] payload)
        ::  This cannot be expressed with just BYSETPOS. Instead we use
        ::  BYMONTHDAY with a list of 7 days starting from the specified
        ::  bound. It doesn't matter if these days go over the end of
        ::  the month due to how RRULEs are parsed (but that would
        ::  indicate some sort of issue with the iana data).
        =/  days-allowed=tape
        %-  zing
        %+  join
          ","
        %+  turn
          (gulf +.payload (add +.payload 6))
        |=(a=@ud `tape`<a>)
        "BYMONTHDAY={days-allowed};"
      ?:  ?=([%instance *] payload)
        ?-  +.payload
            %first   "BYSETPOS=1;"
            %second  "BYSETPOS=2;"
            %third   "BYSETPOS=3;"
            %fourth  "BYSETPOS=4;"
            %last    "BYSETPOS=-1;"
        ==
      !!
      :~  "BYDAY={wday};"
          pos
      ==
      =/  until=tape
      ::  So here we need to calculate how long this rule is in effect
      ::  for. To do so we'll need to reference the rule it's paired
      ::  against. The rule should be ended at a date based on the start
      ::  date of the rule. The ending year should be the min of the end
      ::  year of the `other` rule and this rule. If neither rule has
      ::  an ending year this is the current rule and doesn't need an
      ::  "UNTIL" section.
      ::
      =/  end-year=(unit @ud)
      ?~  to.other
        to.for
      ?~  to.for
        to.other
      (some (min u.to.other u.to.for))
      ?~  end-year
        ""
      =/  end-time=seasoned-time:iana
      %:  build-seasoned-time:liana
          u.end-year
          `in.for
          `on.for
          `offset.at.for
          `flavor.at.for
      ==
      "UNTIL={(da-to-datetime when.end-time =(flavor.end-time %utc))};"
      %-  zing
      %+  weld
        ~["RRULE:FREQ=YEARLY;" "BYMONTH={<in.for>};" until]
      day-sections
    --
  ::
  ++  standard-prefix  "BEGIN:STANDARD"
  ++  standard-suffix  "END:STANDARD"
  ++  daylight-prefix  "BEGIN:DAYLIGHT"
  ++  daylight-suffix  "END:DAYLIGHT"
  ::
  ++  build-dtstart
    |=  from=seasoned-time:iana
    ^-  tape
    %+  weld
      "DTSTART:"
    (da-to-datetime when.from =(flavor.from %utc))
  ::  +build-offset: build signed offset in hours/mins. suitable for
  ::  tzoffset{to,from}
  ::
  ++  build-offset
    |=  =delta:iana
    ^-  tape
    =/  t=tarp  (yell d.delta)
    ?>  =(d.t 0)
    ;:  weld
        ?:(sign.delta "" "-")
        (pad-to-two-digit h.t)
        (pad-to-two-digit m.t)
    ==
  --
--
