/-  *iana-components
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
--
