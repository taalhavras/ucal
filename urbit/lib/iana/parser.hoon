/-  *iana-components, hora
/+  *parser-util, *iana-util
|%
::  +parse-delta: rule for parsing signed time cord in HH:MM or HH:MM:SS format.
::  doesn't assume leading zeros (will parse 1:00 and 01:00 identically)
::  also parses "0" as ~s0
::
++  parse-delta
  ::  rule for parsing one or two digit numbers
  =/  one-or-two
      %+  cook
        from-digits
      (stun [1 2] dit)
  %+  cook
    |=  [sign=flag hr=@ud l=(list @ud)]
    ^-  delta
    =/  hours=@dr  (mul hr ~h1)
    ?~  l
      ::  only support "0" in this manner
      ?>  =(hr 0)
      [| ~s0]
    =/  minutes=@dr  (mul i.l ~m1)
    :-  sign
    ;:  add
      hours
      minutes
      ?~  t.l
        ~s0
      (mul i.t.l ~s1)
    ==
  ::  parse into [sign=flag hours=@ud ~[minutes=@ud seconds=@ud]
  ::  seconds might not be present though.
  ;~  plug
    optional-sign
    one-or-two
    (stun [0 2] (cook tail ;~(plug col one-or-two)))
  ==
::  +can-skip: skip lines that are all whitespace and comments (start
::  with '#')
::
++  can-skip
  |=  line=tape
  ^-  flag
  ?|  (matches line whitespace)
      (matches line ;~(plug (jest '#') (star prn)))
  ==
::  +is-rule-line: checks if a line is part of a rule section
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
  ::  track beginning of zone entries. chosen to be before any other @da
  =/  from=@da  `@da`0
  ::  now replace first line
  =/  lines=wall  [first-line t.lines]
  |-
  ?~  lines
    :: TODO check that the last entry (head of 'entries') is terminal?
    :: if a zone is deprecated that check won't be valid I think.
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
    [[name [u.entry entries]] lines]
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
          (plus ;~(pose alf cab fas))
          ::  now we have whitespace and the continuation
          (plus next)
        ==
    [(crip name) continuation]
  ::
  ++  parse-until
    |=  line=tape
    ^-  (unit @da)
    ~&  [%until-line line]
    ?:  |(=(line "") (matches line whitespace))
      ~
    ::  TODO drop leading whitespace? will we have any?
    =/  segments=wall  (split line whitespace)
::        (split (scan line ;~(pfix whitespace (plus next))) whitespace)
    =/  n=@ud  (lent segments)
    =/  y=@ud  (scan (snag 0 segments) (cook from-digits digits))
    =/  d=date  [[& y] m=1 t=[d=1 h=0 m=0 s=0 f=~]]
    %-  some
    ?:  =(n 1)
      ::  just year
      (year d)
    =/  month-idx=@ud
        %-  ~(got by month-to-idx:hora)
        ;;(month:hora (crip (cass (snag 1 segments))))
    =/  d=date  d(m month-idx)
    ?:  =(n 2)
      ::  year and month
      (year d)
    =/  day=@ud  (slav %ud (crip (snag 2 segments)))
    =/  d=date  d(d.t day)
    ?:  =(n 3)
      ::  year, month, and day
      (year d)
    ::  use delta rule, but this must be positive
    =/  =delta  (scan (snag 3 segments) parse-delta)
    ?>  sign.delta
    ?:  =(n 4)
      ::  year, month, day, time
      (add d.delta (year d))
    !!
  ::  +parse-zone-entry: parses a continuation line
  ::
  ++  parse-zone-entry
    |=  [from=@da line=tape]
    ^-  (unit zone-entry)
    =/  res=(unit [d=delta rules=zone-rules-type format=@t until=(unit @da)])
        %+  rust
          line
        ;~  pfix
          whitespace
          ;~  (glue whitespace)
            ::  STDOFF, delta from utc
            parse-delta
            ::  RULE, nothing, delta, or name of tz-rule
            ;~  pose
              (cook |=(* `zone-rules-type`[%nothing ~]) hep)
              (cook |=(d=delta `zone-rules-type`[%delta d]) parse-delta)
              %+  cook
                |=  name=tape
                `zone-rules-type`[%rule `@ta`(crip name)]
              (plus alf)
            ==
            ::  FORMAT, arbitrary cord. sometimes contains '%s'
            (cook crip (plus ;~(pose alf cen)))
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
      ~&  [%parsing i.lines]
      ?:  (can-skip i.lines)
        $(lines t.lines)
      ?.  (is-rule-line i.lines)
        [entries rule-name lines]
      =/  [entry=rule-entry name=@ta]  (parse-rule-entry i.lines)
      ~&  [%entry entry %name name]
      $(lines t.lines, entries [entry entries], rule-name name)
  ::  must have at least one entry
  ?~  entries
    !!
  =/  tzr=tz-rule
      :-  name
      ::  standard time rules have a delta of 0
      (skid `(list rule-entry)`entries |=(re=rule-entry =(d.save.re ~s0)))
  [tzr continuation]
  |%
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
  ::
  ++  parse-at
    ;~  plug
      %+  cook
        |=  [hours=(list @) @t minutes=(list @)]
        ^-  @dr
        (add (mul (from-digits hours) ~h1) (mul (from-digits minutes) ~m1))
      ;~  plug
        digits
        col
        digits
      ==
      %+  cook
        |=  l=(list @t)
        ^-  rule-at-type
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
  ::  +parse-rule-entry: produce rule entry and name from a line
  ::
  ++  parse-rule-entry
    |=  line=tape
    ^-  [rule-entry @ta]
    =/  [@t name=tape from=@ud to=$@(@ud [@tas ~]) @t month-code=@ud on=rule-on at=[@dr rule-at-type] save=delta letter=char]
        %+  scan
          line
        ;~  sfix
          ;~  (glue whitespace)
            (jest 'Rule')
            ::  NAME
            (plus alf)
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
            parse-at
            ::  SAVE, delta to apply
            parse-delta
            ::  LETTER/S, cord
            (cook crip (plus alf))
          ==
          ::  now there might be trailing whitespace and stuff so
          ::  just parse it and ignore.
          (star prn)
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
--
