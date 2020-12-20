/-  *iana-components, hora
/+  *parser-util, *iana-util
|%
::  +parse-time: parse signed time cord in HH:MM or HH:MM:SS format.
::  doesn't assume leading zeros (will parse 1:00 and 01:00 identically)
::
++  parse-delta
  |=  time=tape
  ^-  delta
  ::  rule for parsing one or two digit numbers
  =/  one-or-two
      %+  cook
        from-digits
      (stun [1 2] dit)
  =/  res
      %+  scan
        time
      ;~  plug
        optional-sign
        one-or-two
        (stun [1 2] (cook tail ;~(plug col one-or-two)))
      ==
  ::  now res is [sign=flag hours=@ud ~[minutes=@ud seconds=@ud]
  ::  seconds might not be present though.
  =/  hours=@dr  (mul +<:res ~h1)
  =/  l=(list @ud)  +>:res
  ?~  l
    !!
  =/  minutes=@dr  (mul i.l ~m1)
  :-  -:res
  ;:  add
    hours
    minutes
    ?~  t.l
      ~s0
    (mul i.t.l ~s1)
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
  ^-  [rule wall]
  =/  r  (turn parse-rule-entry lines)
  !!
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
  ++  parse-rule-entry
    |=  line=tape
    ^-  rule-entry
    =/  res
        %+  scan
          line
        ;~  sfix
          ;~  plug
            (jest 'Rule')
            whitespace
            ::  FROM, year
            digits
            whitespace
            ::  TO, year, 'only', or 'max'
            ;~(pose (jest 'only') (jest 'max') digits)
            whitespace
            ::  deprecated column, always '-'
            hep
            whitespace
            ::  IN, month code
            %+  cook
              (plus alf)
            |=  x=tape
            ^-  @ud
            (~(got by month-to-idx:hora) ;;(month:hora (crip (cass x))))
            whitespace
            ::  ON, specific date
            parse-on
            whitespace
            ::  AT, time offset - can be specified to be local, wallclock,
            ::  or UTC
            !!
            whitespace
            ::  SAVE, delta to apply
            parse-delta
            whitespace
            ::  LETTER, char
            alf
          ==
          ::  now there might be trailing whitespace and stuff so
          ::  just parse it and ignore.
          (plus prn)
        ==
    ~&  [%res res]
    !!
  --
--
