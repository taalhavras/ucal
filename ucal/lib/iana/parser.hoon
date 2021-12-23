/-  *iana-components, hora
/+  *parser-util, *iana-util
|%
::  +parse-time: rule for parsing time in HH:MM or HH:MM:SS format. does
::  not assume leading zeros (will parse 1:00 and 01:00 identically).
::  parses 0 as ~s0, 1 as ~h1, etc.
::
++  parse-time
  ::  rule for parsing one or two digit numbers
  =/  one-or-two
      %+  cook
        from-digits
      (stun [1 2] dit)
  %+  cook
    |=  [hr=@ud l=(list @ud)]
    ^-  @dr
    =/  hours=@dr  (mul hr ~h1)
    ?~  l
      (mul hr ~h1)
    =/  minutes=@dr  (mul i.l ~m1)
    ;:  add
      hours
      minutes
      ?~  t.l
        ~s0
      (mul i.t.l ~s1)
    ==
  ::  parse into [hours=@ud ~[minutes=@ud seconds=@ud]
  ::  seconds might not be present though.
  ;~  plug
    one-or-two
    (stun [0 2] (cook tail ;~(plug col one-or-two)))
  ==

::  +parse-delta: rule for parsing signed time cord in HH:MM or HH:MM:SS format.
::  see +parse-time for specifics.
::
++  parse-delta  ;~(plug optional-sign parse-time)
::
++  parse-offset-and-flavor
  ;~  plug
    parse-time
    %+  cook
      |=  l=(list @t)
      ^-  time-flavor
      ?~  l
        %wallclock
      =/  type=@t  i.l
      ?:  =(type 'w')
        %wallclock
      ?:  =(type 's')
        %standard
      %utc
    %+  stun
      [0 1]
    ;~  pose
      ::  'u', 'g', 'z' are UTC/Greenwich/Zulu
      (jest 'u')
      (jest 'g')
      (jest 'z')
      ::  's' is standard local time
      (jest 's')
      ::  'w' is wall clock time (default)
      (jest 'w')
    ==
  ==
::  +parse-on: rule for parsing the 'ON' component of a tz-rule-entry.
::  Is also used to parse part of the 'UNTIL' component
::
++  parse-on
  ;~  pose
    ::  a specified day of the month
    %+  cook
      from-digits
    (stun [1 2] dit)
    ::  a specific weekday
    %+  cook
      |=  [a=tape monthday=@ud]
      =/  day=weekday:hora  ;;(weekday:hora (crip (cass a)))
      ::  TODO is it worth parsing 1, 8, 15, 22 as first, second,
      ::  third, fourth here? if we have to handle other things anyway
      ::  does it really matter?
      [day [%on monthday]]
    ::  of the form "Sun>=1, Tue>=8, etc.
    ;~  plug
      (plus alf)
      ;~(pfix (jest '>=') (cook from-digits (stun [1 2] dit)))
    ==
    :: last weekday in a month, i.e. lastSun
    %+  cook
      |=  a=tape
      =/  day=weekday:hora  ;;(weekday:hora (crip (cass a)))
      [day [%instance %last]]
    ;~  pfix
      (jest 'last')
      (plus alf)
    ==
  ==
::  +can-skip: skip lines that are all whitespace and comments (start
::  with '#') as well as blank lines.
::
++  can-skip
  |=  line=tape
  ^-  flag
  ?|  (matches line whitespace)
      (startswith line (jest '#'))
      =(line "")
  ==
::  +is-rule-line: checks if a line is part of a rule section.
::
++  is-rule-line
  |=  line=tape
  ^-  flag
  (startswith line (jest 'Rule'))
::
++  is-zone-line
  |=  line=tape
  ^-  flag
  (startswith line (jest 'Zone'))
::  +parse-zone: given lines, produce zone and continuation
::
++  parse-zone
  =<
  |=  lines=wall
  ^-  [zone wall]
  ::  first line is different than continuation line so we process it
  ::  separately.
  ?~  lines
    !!
  =/  [name=@t first-line=tape]  (parse-first-line i.lines)
  =|  entries=(list zone-entry)
  ::  track beginning of zone entries. time chosen to be before any other @da
  =/  from=seasoned-time  [`@da`0 %wallclock]
  ::  now replace first line
  =/  lines=wall  [first-line t.lines]
  |-
  ?~  lines
    :: we cannot check that the last entry (head of 'entries') is
    :: terminal because a zone might be deprecated
    [[name entries] ~]
  ?:  (can-skip i.lines)
    $(lines t.lines)
  =/  entry=(unit zone-entry)  (parse-zone-entry from i.lines)
  ::  if entry is ~, then the line was not parseable as a continuation
  ::  to the current zone - bail out.
  ?~  entry
    [[name entries] lines]
  ?~  to.u.entry
    ::  if this is none we can bail out (assuming these are always
    ::  in chronological order).
    [[name [u.entry entries]] t.lines]
  ::  otherwise recur onto remaining lines, updating "from"
  $(lines t.lines, entries [u.entry entries], from u.to.u.entry)
  |%
  ++  parse-first-line
    |=  line=tape
    ^-  [@t tape]
    =/  [@t ~ name=tape continuation=tape]
        %+  scan
          line
        ;~  plug
          (jest 'Zone')
          whitespace
          ::  NAME
          (plus ;~(pose aln cab fas hep))
          ::  now we have whitespace and the continuation
          (plus next)
        ==
    [(crip name) continuation]
  ::
  ++  parse-until
    |=  line=tape
    ^-  (unit seasoned-time)
    ?:  |(=(line "") (matches line whitespace))
      ~
    ::  TODO drop leading whitespace? will we have any?
    =/  segments=wall  (split line whitespace)
    =/  n=@ud  (lent segments)
    =/  y=@ud  (scan (snag 0 segments) (cook from-digits digits))
    =/  d=date  [[& y] m=1 t=[d=1 h=0 m=0 s=0 f=~]]
    %-  some
    ?:  =(n 1)
      ::  just year
      [(year d) %wallclock]
    =/  month-idx=@ud
        %-  ~(got by month-to-idx:hora)
        ;;(month:hora (crip (cass (snag 1 segments))))
    =/  d=date  d(m month-idx)
    ?:  =(n 2)
      ::  year and month
      [(year d) %wallclock]
    ::  now we have a  a value analogous to a rule's "ON" component (i.e. lastSun, Mon>=3, etc.)
    =/  on=rule-on  (scan (snag 2 segments) parse-on)
    ?:  =(n 3)
      ::  year, month, and day w/no specified time
      (build-seasoned-time y `month-idx `on ~ `%wallclock)
    =/  [offset=@dr flavor=time-flavor]
        (scan (snag 3 segments) parse-offset-and-flavor)
    ?:  =(n 4)
      ::  year, month, day, time
      (build-seasoned-time y `month-idx `on `offset `flavor)
    !!
  ::  +parse-zone-entry: parses a continuation line
  ::
  ++  parse-zone-entry
    |=  [from=seasoned-time line=tape]
    ^-  (unit zone-entry)
    =/  res=(unit [d=delta ~ rules=zone-rules-type ~ format=@t (list ~) until=(unit seasoned-time)])
        %+  rust
          line
        ;~  pfix
          whitespace
          ;~  plug
            ::  STDOFF, delta from utc
            parse-delta
            whitespace
            ::  RULE, nothing, delta, or name of tz-rule
            ;~  pose
              :: order here is important - since negative deltas also
              :: start with hep we should consider them first.
              (cook |=(d=delta `zone-rules-type`[%delta d]) parse-delta)
              (cook |=(* `zone-rules-type`[%nothing ~]) hep)
              %+  cook
                |=  name=tape
                `zone-rules-type`[%rule `@ta`(crip name)]
              (plus ;~(pose alf cab hep))
            ==
            whitespace
            ::  FORMAT, arbitrary cord. sometimes contains '%s',
            ::  sometimes is '-00', sometimes contains '/', sometimes
            ::  contains '+'
            (cook crip (plus ;~(pose aln cen hep fas lus)))
            (stun [0 1] whitespace)
            ::  UNTIL, optional, end of entry. if omitted, entry
            ::  is valid until the present.
            %+  cook
              parse-until
            (star next)
          ==
        ==
    ?~  res
      ~
    `[d.u.res rules.u.res format.u.res from until.u.res]
  --
::
++  parse-rule
  =<
  |=  lines=wall
  ^-  [tz-rule wall]
  =/  [entries=(list rule-entry) name=@ta continuation=wall]
      =|  entries=(list rule-entry)
      =|  rule-name=@ta
      |-
      ?~  lines
        [entries rule-name ~]
      ::  FIXME currently special cases out lines containing '<=' as well.
      ::  This is only used once as of 02/21/2021 - for Rule 'Zion'
      ::  and isn't currently supported.
      ?:  |((can-skip i.lines) !=((find "<=" i.lines) ~))
        $(lines t.lines)
      ?.  (is-rule-line i.lines)
        [entries rule-name lines]
      =/  [entry=rule-entry name=@ta]  (parse-rule-entry i.lines)
      $(lines t.lines, entries [entry entries], rule-name name)
  ::  must have at least one entry
  ?~  entries
    !!
  =/  tzr=tz-rule
      :-  name
      (skid `(list rule-entry)`entries is-standard)
  [tzr continuation]
  |%
  ::  +parse-rule-entry: produce rule entry and name from a line
  ::
  ++  parse-rule-entry
    |=  line=tape
    ^-  [rule-entry @ta]
    =/  [@t name=tape from=@ud to=$@(@ud [@tas ~]) @t month-code=@ud on=rule-on at=[@dr time-flavor] save=delta letter=cord]
        %+  scan
          line
        ;~  sfix
          ;~  (glue whitespace)
            (jest 'Rule')
            ::  NAME
            (plus ;~(pose alf cab hep))
            ::  FROM, year
            (cook from-digits digits)
            ::  TO, year, 'only', or 'max'
            ;~  pose
              (cook |=(* [%only ~]) (jest 'only'))
              (cook |=(* [%max ~]) (jest 'max'))
              (cook from-digits digits)
            ==
            ::  deprecated column, always '-'
            hep
            ::  IN, month code
            %+  cook
              |=  x=tape
              ^-  @ud
              (~(got by month-to-idx:hora) ;;(month:hora (crip (cass x))))
            (plus alf)
            ::  ON, specific date
            parse-on
            ::  AT, time offset - can be specified to be local, wallclock,
            ::  or UTC
            parse-offset-and-flavor
            ::  SAVE, delta to apply
            parse-delta
            ::  LETTER/S, cord
            ::  while you'd like to imagine this field containing solely
            ::  LETTERS, it can sometimes contain signed numbers!
            ::  see: Belize (northamerica) is -0530
            ::  Ghana (africa) is +0020
            (cook crip (plus ;~(pose aln hep lus)))
          ==
          ::  now there might be trailing whitespace and stuff so
          ::  just parse it and ignore.
          (star next)
        ==
    =/  to=(unit @ud)
        ?@  to
          `to
        ?:  =(%only -:to)
          `from
        ~
    :_  `@ta`(crip name)
    :*  from
        to
        month-code
        on
        at
        save
        letter
    ==
  --
::  +is-link-line: check if line is a Link line
::
++  is-link-line
  |=  line=tape
  ^-  flag
  (startswith line (jest 'Link'))
::  +parse-link: parse a link line (creates timezone alias). head of
::  cell is the name of the alias and the tail is the existing zone.
::
++  parse-link
  |=  line=tape
  ^-  [@t @t]
  =/  tokens=wall  (split line whitespace)
  [(crip (snag 2 tokens)) (crip (snag 1 tokens))]
::  +parse-timezones: top level parser to go from file contents to
::  tzrules and zones (keyed by name)
::
++  parse-timezones
  |=  input=wall
  ^-  [(map @t zone) (map @t tz-rule) (map @t @t)]
  =/  lines=wall
      %+  turn
        input
      |=  line=tape
      ^-  tape
      (strip-trailing-whitespace (remove-inline-comments line))
  =|  zones=(map @t zone)
  =|  rules=(map @t tz-rule)
  =|  links=(map @t @t)
  |-
  ?~  lines
    [zones rules links]
  ?:  (can-skip i.lines)
    $(lines t.lines)
  ?:  (is-rule-line i.lines)
    =/  [tzr=tz-rule continuation=wall]  (parse-rule lines)
    $(rules (~(put by rules) name.tzr tzr), lines continuation)
  ?:  (is-zone-line i.lines)
    =/  [zon=zone continuation=wall]  (parse-zone lines)
    $(zones (~(put by zones) name.zon zon), lines continuation)
  ?:  (is-link-line i.lines)
    =/  [alias=@t real=@t]  (parse-link i.lines)
    $(links (~(put by links) alias real), lines t.lines)
  ~&  [%unparseable-timezone-line i.lines]
  $(lines t.lines)
--
