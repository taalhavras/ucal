/-  *iana-components, hora
/+  *parser-util, *iana-util
|%
::  +parse-delta: rule for parsing signed time cord in HH:MM or HH:MM:SS format.
::  doesn't assume leading zeros (will parse 1:00 and 01:00 identically)
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
      !!
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
    (stun [1 2] (cook tail ;~(plug col one-or-two)))
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
::  +parse-zone: given lines, produce zone and continuation
::
++  parse-zone
  =<
  |=  lines=wall
  ^-  [zone wall]
  !!
  |%
  ++  parse-zone-entry
    |=  line=tape
    ^-  zone-entry
    !!
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
      ?:  (can-skip i.lines)
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
      ::  standard time rules have a delta of 0
      (skid `(list rule-entry)`entries |=(re=rule-entry =(d.save.re ~s0)))
  [tzr continuation]
  |%
  ++  is-rule-line
    |=  line=tape
    ^-  flag
    (matches line ;~(plug (jest 'Rule') (star prn)))
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
        =/  day=weekday:hora  ;;(weekday:hora (crip a))
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
        =/  day=weekday:hora  ;;(weekday:hora (crip a))
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
        ^-  @tas
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
    =/  res
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
            ;~(pose (jest 'only') (jest 'max') digits)
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
            ::  LETTER, char
            alf
          ==
          ::  now there might be trailing whitespace and stuff so
          ::  just parse it and ignore.
          (star prn)
        ==
    ~&  [%res res]
    !!
  --
--
