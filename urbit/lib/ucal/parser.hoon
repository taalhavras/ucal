/-  *ucal-components
/+  pretty-file
::  Core for parsing .ics files containing VEVENTs and VALARMs
::
|%
::  galf: reverse flag type, defaults to false.
::
::    used for more convenient initialization with =|
::    for some types, see required-tags/unique-tags
::
++  galf  $~(| ?)
::  +matches:  checks whether a tape matches a given rule
::
++  matches
  |*  [t=tape rul=rule]
  ^-  flag
  =/  res  (rust t rul)
  !=(res ~)
::  +process-line:  splits a line into tag, data, and properties
::
::    lines are of the form  TAG*(;PROP=PVAL):DATA
::    tag is generated from the input mold m being applied to TAG
::    data is just DATA
::    properties is a map from PROP to PVAL
::
++  process-line
  |*  [t=tape m=mold]
  ^-  (unit [m tape (map tape tape)])
  =/  tokens=(list tape)  (split-first t col)
  ?>  =((lent tokens) 2)
  =/  props=(list tape)  (split (snag 0 tokens) mic)
  =/  tag=(unit m)  ((soft m) (crip (cass (snag 0 props))))
  ?~  tag
    ~
  =|  props-map=(map tape tape)
  =/  props-list=(list [tape tape])
    %+  turn
      (slag 1 props)
    |=  tok=tape
    =/  components=(list tape)  (split tok tis)
    ?>  =((lent components) 2)
    [(snag 0 components) (snag 1 components)]
  `[u.tag (snag 1 tokens) (~(gas by props-map) props-list)]
::  +in-between:  checks if lower <= x <= higher
::
++  in-between
  |=  [[lower=@ higher=@] x=@]
  ^-  flag
  ?&((lte lower x) (gte higher x))
::  +valid-*:  utilities for validating parts of times.
::
++  valid-month  (bake (cury in-between [0 12]) @)
++  valid-hour  (bake (cury in-between [0 23]) @)
++  valid-min  (bake (cury in-between [0 59]) @)
++  valid-sec  (bake (cury in-between [0 60]) @) ::  60 for leap seconds
++  valid-monthday  (bake (cury in-between [1 31]) @)
++  valid-yearday  (bake (cury in-between [1 366]) @) ::  366 for leap years
++  valid-weeknum  (bake (cury in-between [1 53]) @)
::  +whut:  rule builder for matching 0 or 1 time. regex '?'
::
++  whut  |*(rul=rule (stun [0 1] rul))
::
++  digits  (plus dit)
::
++  two-dit  ;~(plug dit dit)
::
++  four-dit  ;~(plug dit dit dit dit)
::  +optional-sign:  rule for parsing optional signs.
::
++  optional-sign
  %+  cook
    |=(x=tape !=(x "-"))  ::  %.y if we don't have '-', %.n otherwise
  (whut ;~(pose lus hep))  ::  the sign itself is optional
::  +split:  split input tape on delim rule
::
++  split
  |*  [t=tape delim=rule]
  ^-  (list tape)
  ::  rule to match "words" or non-delim strings
  ::
  =/  w  (star ;~(less delim next))
  %+  fall
    (rust t (more delim w))
  ~[t]
::  +split-first:  splits a tape on the first instance of a delimiter.
::
++  split-first
  |*  [t=tape delim=rule]
  ^-  (list tape)
  =/  res  (rust t ;~(plug (star ;~(less delim next)) delim (star next)))
  ?~  res
    ~[t]
  ~[-:u.res +>:u.res]
::  +from-two-digit:  cell of two digits to a single atom (tens and ones place)
::
++  from-two-digit  |=  [a=@ b=@]  (add (mul 10 a) b)
::  +from-digits:  converts a list of digits to a single atom
::
++  from-digits
  |=  l=(list @)
  ^-  @ud
  (roll l |=([cur=@ud acc=@ud] (add (mul 10 acc) cur)))
::
++  parse-rdate-values
  |=  [t=tape props=(map tape tape)]
  ^-  (list rdate)
  =/  tokens=(list tape)  (split t com)
  =/  f=$-(tape rdate)
  =/  res=(unit tape)  (~(get by props) "VALUE")
  ::  value sig or not period, it's a date or datetime
  ::
  ?:  |(?=($~ res) !=(u.res "PERIOD"))
    |=(tok=tape [%time (parse-date-or-datetime tok)])
  |=(tok=tape [%period (parse-period tok)])
  (turn tokens f)
::
++  parse-utc-offset
  |=  t=tape
  ^-  utc-offset
  =/  res
  %+  scan
    t
  ::  tape is formatted as an optional sign then HHMMSS
  ::  for hours, minutes, and optionally seconds (default to 0)
  ::
  ;~
    plug
    optional-sign
    (cook from-two-digit two-dit)
    (cook from-two-digit two-dit)
    (whut (cook from-two-digit two-dit))
  ==
  =/  hour=@  +<:res
  =/  minute=@  +>-:res
  =/  second-val  +>+:res
  =/  second=@
  ?~  second-val
    0
  -:second-val
  :-
    -:res
  `@dr`(yule [0 hour minute second ~])
::
++  parse-recur
  =<
  |=  t=tape
  ^-  rrule
  =/  tokens=(list tape)  (split t mic)
  =/  parts=(map tape tape)  (produce-parts-map tokens)
  :*
    (parse-freq parts)
    (parse-until parts)
    (parse-count parts)
    (parse-interval parts)
    (parse-bysecond parts)
    (parse-byminute parts)
    (parse-byhour parts)
    (parse-byweekday parts)
    (parse-bymonthday parts)
    (parse-byyearday parts)
    (parse-byweek parts)
    (parse-bymonth parts)
    (parse-bysetpos parts)
    (parse-weekstart parts)
  ==
  |%
  ::  $validator:  functions that test if atoms have certain properties
  ::
  +$  validator  $-(@ flag)
  ::  +produce-parts-map: maps the unique parts of an rrule to their values
  ::
  ++  produce-parts-map
    |=  l=(list tape)
    ^-  (map tape tape)
    =|  acc=(map tape tape)
    |-
    ?~  l
      acc
    =/  tokens=(list tape)  (split i.l tis)
    ?>  =((lent tokens) 2)
    =/  key=tape  (snag 0 tokens)
    ::  check for key being unique
    ::
    ?~  (~(get by acc) key)
      $(l t.l, acc (~(put by acc) key (snag 1 tokens)))
    !!
  ::
  ++  parse-freq
    |=  parts=(map tape tape)
    ^-  rrule-freq
    (^:(rrule-freq) (crip (cass (~(got by parts) "FREQ"))))
  ::
  ++  parse-until
    |=  parts=(map tape tape)
    ^-  (unit ical-time)
    (bind (~(get by parts) "UNTIL") parse-date-or-datetime)
  ::
  ++  parse-count
    |=  parts=(map tape tape)
    ^-  (unit @)
    %+  bind
    (~(get by parts) "COUNT")
    (curr scan (cook from-digits digits))
  ::
  ++  parse-interval
    |=  parts=(map tape tape)
    ^-  @
    %+  fall
      %+  bind
        (~(get by parts) "INTERVAL")
      (curr scan (cook from-digits digits))
    1  ::  default value is 1
  ::  +parse-and-validate-two-digits: list of two-digit atoms from tape,
  ::  asserting validator.
  ::
  ++  parse-and-validate-two-digits
    |=  [t=tape v=validator]
    ^-  (list @)
    =/  tokens=(list tape)  (split t com)
    %+  turn
      tokens
    |=  tok=tape
        ^-  @
        %+  scan
          tok
        %+  cook
          |=  digits=[@ @]
              ^-  @
              =/  res=@  (from-two-digit digits)
              ?>  (v res)
              res
        two-dit
  ::
  ++  parse-bysecond
    |=  parts=(map tape tape)
    ^-  (list @)
    =/  res=(unit tape)  (~(get by parts) "BYSECOND")
    ?~  res
      ~
    (parse-and-validate-two-digits u.res valid-sec)
  ::
  ++  parse-byminute
    |=  parts=(map tape tape)
    ^-  (list @)
    =/  res=(unit tape)  (~(get by parts) "BYMINUTE")
    ?~  res
      ~
    (parse-and-validate-two-digits u.res valid-min)
  ::
  ++  parse-byhour
    |=  parts=(map tape tape)
    ^-  (list @)
    =/  res=(unit tape)  (~(get by parts) "BYHOUR")
    ?~  res
      ~
    (parse-and-validate-two-digits u.res valid-hour)
  ::  +parse-and-validate-sign-and-atom:  @s from tape,
  ::  asserting validator on absolute value of s.
  ::
  ++  parse-and-validate-sign-and-atom
    |=  [t=tape v=validator]
    ^-  (list @s)
    =/  tokens=(list tape)  (split t com)
    %+  turn
      tokens
    |=  tok=tape
        ^-  @s
        =/  [sign=? a=@]
        %+  scan
          tok
        ;~
          plug
          optional-sign
          (cook from-digits digits)
        ==
        ?>  (v a)
        (new:si sign a)
  ::
  ++  parse-byweekday
    |=  parts=(map tape tape)
    ^-  (list rrule-weekdaynum)
    =/  res=(unit tape)  (~(get by parts) "BYDAY")
    ?~  res
      ~
    =/  tokens=(list tape)  (split u.res com)
    %+  turn
      tokens
    |=  t=tape
        =/  res
            %+  scan
              t
            ;~
              plug
              %-  whut
              ;~
                plug
                optional-sign
                (cook from-digits digits)
              ==
              ;~(plug hig hig)
            ==
        ::  day should always be present
        ::
        =/  day=rrule-day
            (^:(rrule-day) (crip (cass ~[+<:res +>:res])))
        ::  now, we must go through the various cases
        ::
        =/  hd  -:res
        ?~  hd
          ::  we didn't have a sign or a number
          ::
          :-(day ~)
        =/  num=@  -<+:res
        ?>  (valid-weeknum num)
        =/  sign=flag  -<-:res
        :-
          day
        `(new:si sign num)
  ::
  ++  parse-bymonthday
    |=  parts=(map tape tape)
    ^-  (list rrule-monthdaynum)
    =/  res=(unit tape)  (~(get by parts) "BYMONTHDAY")
    ?~  res
      ~
    %+  parse-and-validate-sign-and-atom
      u.res
    valid-monthday
  ::
  ++  parse-byyearday
    |=  parts=(map tape tape)
    ^-  (list rrule-yeardaynum)
    =/  res=(unit tape)  (~(get by parts) "BYYEARDAY")
    ?~  res
      ~
    %+  parse-and-validate-sign-and-atom
      u.res
    valid-yearday
  ::
  ++  parse-byweek
    |=  parts=(map tape tape)
    ^-  (list rrule-weeknum)
    =/  res=(unit tape)  (~(get by parts) "BYWEEKNO")
    ?~  res
      ~
    %+  parse-and-validate-sign-and-atom
      u.res
    valid-weeknum
  ::
  ++  parse-bymonth
    |=  parts=(map tape tape)
    ^-  (list rrule-monthnum)
    =/  res=(unit tape)  (~(get by parts) "BYMONTH")
    ?~  res
      ~
    %+  parse-and-validate-sign-and-atom
      u.res
    valid-month
  ::
  ++  parse-bysetpos
    |=  parts=(map tape tape)
    ^-  (list rrule-monthnum)
    =/  res=(unit tape)  (~(get by parts) "BYSETPOS")
    ?~  res
      ~
    %+  parse-and-validate-sign-and-atom
      u.res
    valid-yearday ::  also yearday
  ::
  ++  parse-weekstart
    |=  parts=(map tape tape)
    ^-  rrule-day
    %+  fall
      %+  bind
        (~(get by parts) "WKST")
      ;:(cork cass crip ^:(rrule-day))
    %mo  ::  monday is default value
  --
::  +parse-float:  parses a signed floating point (base 10) from a tape
::
++  parse-float
  |=  t=tape
  ^-  dn
  =/  rul
      ;~
        plug
        optional-sign
        digits
        (whut ;~(plug dot digits))
      ==
  =/  res  (scan t rul)
  =/  d=dn  [%d s=-:res e=--0 a=0]
  ::  get number before decimal point
  ::
  =/  before-decimal=@  (from-digits `(list @)`+<:res)
  ::  get part after decimal point (includes decimal)
  ::
  =/  decimal  +>:res
  ?~  decimal
    [%d s=-:res e=--0 a=before-decimal]
  =/  decimal-digits=(list @)  `(list @)`->:decimal
  ::  so now we want to multiply num by 10^(lent decimal-digits) and
  ::  set our exponent (e) in d to -(lent decimal-digits).
  ::
  =/  exponent=@  (lent decimal-digits)
  =/  mantissa=@
      %+  add
        (mul before-decimal (pow 10 exponent))
      (from-digits decimal-digits)
  ::  signed representation is one less than twice absolute value e.g.
  ::  ^-  @  `@s`-2
  ::  produces 3
  ::
  =/  neg-exponent=@s  (dec (mul 2 exponent))
  [%d s=-:res e=neg-exponent a=mantissa]
::
++  parse-period
  |=  t=tape
  ^-  period
  ::  split on '/'. first token is a date-time, second will either be
  ::  date-time or duration. the duration MUST BE POSITIVE
  ::
  =/  tokens=(list tape)  (split t fas)
  ?>  =((lent tokens) 2)
  =/  begin=ical-datetime  (parse-datetime-value (snag 0 tokens))
  =/  second=tape  (snag 1 tokens)
  ::  matches prefix of duration
  ::
  =/  dur-rul  ;~(plug ;~(pose lus hep) (jest 'P'))
  ?:  (matches second ;~(plug dur-rul (star next)))
    ::  we have a date-time for the second
    ::
    [%explicit begin (parse-datetime-value second)]
  =/  [sign=? dur=@dr]  (parse-duration second)
  ::  duration must be positive
  ::
  ?>  sign
  [%start begin dur]
::
++  parse-duration
  =<
  |=  t=tape
  ^-  ical-duration
  =/  dur-sec  (cook cook-sec ;~(plug digits (jest 'S')))
  =/  dur-min  (cook cook-min ;~(plug digits (jest 'M') (whut dur-sec)))
  =/  dur-hour  (cook cook-hour ;~(plug digits (jest 'H') (whut dur-min)))
  =/  dur-day  (cook cook-day ;~(plug digits (jest 'D')))
  =/  dur-week  (cook cook-week ;~(plug digits (jest 'W')))
  =/  dur-time  (cook cook-time ;~(plug (jest 'T') ;~(pose dur-hour dur-min dur-sec)))
  =/  dur-date  (cook cook-date ;~(plug dur-day (whut dur-time)))
  =/  res=[f=? =cord tar=tarp]
  %+  scan
    t
  ;~
    plug
    optional-sign
    (jest 'P')
    ;~
      pose
      dur-time
      dur-date
      dur-week
    ==
  ==
  [f.res `@dr`(yule tar.res)]
  |%
  ::
  ++  cook-week
    |=  [digits=(list @) =cord]
    ^-  tarp
    =|  tar=tarp
    tar(d (mul 7 (from-digits digits)))
  ::
  ++  cook-sec
    |=  [digits=(list @) =cord]
    ^-  tarp
    =|  tar=tarp
    tar(s (from-digits digits))
  ::
  ++  cook-min
    |=  [digits=(list @) =cord sec=*]
    ^-  tarp
    =|  tar=tarp
    =/  minutes=@  (from-digits digits)
    ?~  sec
      tar(m minutes)
    ::  we have seconds to parse
    ::
    =/  secs=tarp  (^:(tarp) -:sec)
    secs(m minutes)
  ::
  ++  cook-hour
    |=  [digits=(list @) =cord min=*]
    ^-  tarp
    =|  tar=tarp
    =/  hours=@  (from-digits digits)
    ?~  min
      tar(h hours)
    ::  parse minutes
    ::
    =/  mins=tarp  (^:(tarp) -:min)
    mins(h hours)
  ::
  ++  cook-day
    |=  [digits=(list @) =cord]
    ^-  tarp
    =|  tar=tarp
    tar(d (from-digits digits))
  ::
  ++  cook-time
    |=  [=cord t=tarp]
    ^-  tarp
    t
  ::
  ++  cook-date
    |=  [day=tarp time=*]
    ^-  tarp
    ::  if we have no time, just use day value, otherwise
    ::  combine both
    ::
    ?~  time
      day
    =/  timetarp=tarp  (^:(tarp) -:time)
    timetarp(d d.day)
  --
::  +parse-date-or-datetime:  used to parse tapes that are
::  either dates or datetimes
::
++  parse-date-or-datetime
  |=  t=tape
  ^-  ical-time
  ::  check if length of tape is 8. If it is, dtstamp is a date.
  ::  otherwise, it's a date-time
  ::
  ?:  =((lent t) 8)
    (parse-date-value t)
  (parse-datetime-value t)
::  +parse-date-value:  parse an ics date value - a tape of the form "YYYYMMDD"
::
++  parse-date-value
  |=  t=tape
  ^-  ical-date
  =|  d=date
  ::  parse tape into [[Y Y Y Y] [M M] [D D]]
  ::
  =/  res  (scan t ;~(plug four-dit two-dit two-dit))
  =/  day=@  (from-two-digit +>:res)
  =/  month=@  (from-two-digit +<:res)
  =/  yc=[a=@ b=@ c=@ d=@]  -:res
  ::  computes 1000*a + 100*b + 10*c + d
  ::
  =/  yer=@
      %+  add
        (mul 100 (from-two-digit [a.yc b.yc]))
      (from-two-digit [c.yc d.yc])
  [%date `@da`(year d(y yer, m month, d.t day))]
::  +parse-datetime-value:  parses an ics datetime.
::
::    formatted as: YYYYMMDD followed by a 'T' and then the time.
::    time is formatted as HHMMSS for hour, minute, and second.
::    optionally, there may also be a 'Z' at the end, signifying UTC time
::
++  parse-datetime-value
  |=  t=tape
  ^-  ical-datetime
  =/  tokens=(list tape)  (split t (jest 'T'))
  ?>  =((lent tokens) 2)
  =/  d=ical-date  (parse-date-value (snag 0 tokens))
  =/  two-digit  ;~(plug dit dit)
  =/  res
      %+  scan
        (snag 1 tokens)
      ;~
        plug
        two-digit
        two-digit
        two-digit
        (whut (jest 'Z'))
      ==
  =/  hours=@  (from-two-digit -:res)
  ?>  (valid-hour hours)
  =/  minutes=@  (from-two-digit +<:res)
  ?>  (valid-min minutes)
  =/  seconds=@  (from-two-digit +>-:res)
  ?>  (valid-sec seconds)
  =/  utc=?  =(+>+:res "Z")
  [%date-time `@da`(add d.d (yule [0 hours minutes seconds ~])) utc]
::
++  parse-vtimezone
  =<
  |=  w=wall
  ^-  (unit vtimezone)
  =|  v=vtimezone
  =|  rt=required-tags
  =|  ut=unique-tags
  |-
  ?~  w
    ?:  &(tzid.rt (gte (lent props.v) 1))
      `v
    ~
  =/  res  (process-line i.w vtimezone-tag)
  ?~  res
    $(w t.w)
  =/  [tag=vtimezone-tag tok=tape props=(map tape tape)]  u.res
  =/  parser
  ?-  tag
    %tzid  parse-tzid
    %last-mod  parse-last-modified
    %tzurl  parse-tzurl
    %begin  parse-subcomponent
  ==
  =/  parsed=[vt=vtimezone rt=required-tags ut=unique-tags w=wall]
      (parser tok t.w props v rt ut)
  $(w w.parsed, v vt.parsed, rt rt.parsed, ut ut.parsed)
  |%
  ::  $required-tags:  tags we expect a vtimezone to specify exactly once
  ::
  +$  required-tags
    $:
      tzid=galf
    ==
  ::  $unique-tags:  tags we expect a vtimezone to specify no more than once
  ::
  +$  unique-tags
    $:
      last-mod=galf
      tzurl=galf
    ==
  ::  $vtimezone-tag:  tags specified in a vtimezone
  ::
  +$  vtimezone-tag
    $?
      %tzid
      %last-mod
      %tzurl
      %begin
    ==
  ::  $tzprop-tag:  tags specified in a tzprop
  ::
  +$  tzprop-tag
    $?
      %dtstart
      %tzoffsetto
      %tzoffsetfrom
      %rrule
      %rdate
      %comments
      %tzname
    ==
  ::
  ++  parse-tzid
    |=  [t=tape rest=wall props=(map tape tape) v=vtimezone rt=required-tags ut=unique-tags]
    ^-  [vtimezone required-tags unique-tags wall]
    ?<  tzid.rt
    :^
    v(id (tzid t))
    rt(tzid &)
    ut
    rest
  ::
  ++  parse-subcomponent
    |=  [t=tape rest=wall props=(map tape tape) v=vtimezone rt=required-tags ut=unique-tags]
    ^-  [vtimezone required-tags unique-tags wall]
    =/  end-idx=@  (need (find ~[(weld "END:" t)] rest))
    =/  prop-lines=wall  (scag end-idx rest)
    =/  rest-lines=wall  (slag +(end-idx) rest)
    =/  prop=tzprop  (parse-tzprop prop-lines)
    ::  only "STANDARD" or "DAYLIGHT" can be nested inside a vtimezone
    ::
    =/  component=tzcomponent
        ^-  tzcomponent
        =/  tag=term  (crip (cass t))
        ?+  tag  !!
          %standard  [%standard prop]
          %daylight  [%daylight prop]
        ==
    :^
    v(props [component props.v])
    rt
    ut
    rest-lines
  ::
  ++  parse-last-modified
    |=  [t=tape rest=wall props=(map tape tape) v=vtimezone rt=required-tags ut=unique-tags]
    ^-  [vtimezone required-tags unique-tags wall]
    ?<  last-mod.ut
    :^
    v(last-modified `(parse-datetime-value t))
    rt
    ut(last-mod &)
    rest
  ::
  ++  parse-tzurl
    |=  [t=tape rest=wall props=(map tape tape) v=vtimezone rt=required-tags ut=unique-tags]
    ^-  [vtimezone required-tags unique-tags wall]
    ?<  tzurl.ut
    :^
    v(url `t)
    rt
    ut(tzurl &)
    rest
  ::
  ++  parse-tzprop
    |=  w=wall
    ^-  tzprop
    =|  acc=(jar tzprop-tag [tape (map tape tape)])
    =/  acc=(jar tzprop-tag [tape (map tape tape)])
        |-
        ?~  w
          acc
        =/  res  (process-line i.w tzprop-tag)
        ?~  res
          $(w t.w)
        =/  [k=tzprop-tag v=[tape (map tape tape)]]  u.res
        $(w t.w, acc (~(add ja acc) k v))
    :*
      (parse-dtstart acc)
      (parse-tzoffsetto acc)
      (parse-tzoffsetfrom acc)
      (parse-rrule acc)
      (parse-rdate acc)
      (parse-comments acc)
      (parse-tzname acc)
    ==
  ::
  ++  parse-dtstart
    |=  j=(jar tzprop-tag [tape (map tape tape)])
    ^-  @da
    =/  dtstart-list  (~(get ja j) %dtstart)
    ?>  =((lent dtstart-list) 1)
    =/  [t=tape =(map tape tape)]  (snag 0 dtstart-list)
    =/  dtstart=ical-time  (parse-date-or-datetime t)
    ?:  ?=([%date *] dtstart)
      d.dtstart
    ::  datetime cannot be utc
    ::
    ?<  utc.dtstart
    d.dtstart
  ::
  ++  parse-tzoffsetto
    |=  j=(jar tzprop-tag [tape (map tape tape)])
    ^-  utc-offset
    =/  offsetto-list  (~(get ja j) %tzoffsetto)
    ?>  =((lent offsetto-list) 1)
    =/  [t=tape =(map tape tape)]  (snag 0 offsetto-list)
    (parse-utc-offset t)
  ::
  ++  parse-tzoffsetfrom
    |=  j=(jar tzprop-tag [tape (map tape tape)])
    ^-  utc-offset
    =/  offsetto-list  (~(get ja j) %tzoffsetfrom)
    ?>  =((lent offsetto-list) 1)
    =/  [t=tape =(map tape tape)]  (snag 0 offsetto-list)
    (parse-utc-offset t)
  ::
  ++  parse-rrule
    |=  j=(jar tzprop-tag [tape (map tape tape)])
    ^-  (unit rrule)
    =/  rrule-list  (~(get ja j) %rrule)
    ?~  rrule-list
      ~
    ?>  =((lent rrule-list) 1)
    =/  [t=tape =(map tape tape)]  i.rrule-list
    `(parse-recur t)
  ++  parse-rdate
    |=  j=(jar tzprop-tag [tape (map tape tape)])
    ^-  (list rdate)
    %-  zing
    (turn (~(get ja j) %rdate) parse-rdate-values)
  ::
  ++  parse-comments
    |=  j=(jar tzprop-tag [tape (map tape tape)])
    ^-  (list tape)
    %+  turn
      (~(get ja j) %comments)
    |=([t=tape =(map tape tape)] t)
  ::
  ++  parse-tzname
    |=  j=(jar tzprop-tag [tape (map tape tape)])
    ^-  (list tape)
    %+  turn
    (~(get ja j) %tzname)
    |=([t=tape =(map tape tape)] t)
  --
++  parse-valarm
  =<
  |=  w=wall
  ^-  (unit valarm)
  ::  Split lines into action prop and others. Once we have
  ::  the action prop, we can call the specific parser for
  ::  the particular type of valarm. see valarm-action
  ::  for supported action types.
  ::
  =/  action-rul
      ;~(plug (jest 'ACTION') (star ;~(less col next)) col (star next))
  =/  [actions=wall rest=wall]
      %+  skid
        w
      (curr matches action-rul)

  ::  action is a unique tag
  ?>  =((lent actions) 1)
  =/  action-prop=tape  (snag 1 (split (snag 0 actions) col))
  =/  action=(unit valarm-action)
      ((soft valarm-action) (crip (cass action-prop)))
  ?~  action
    ~
  ::  Now we know we have a valid action, we want to preprocess
  ::  the remaining lines. We map the tags to a list of
  ::  [data=tape props=(map tape tape)].
  ::  Something like "FOO;BAR=BAZ:QUX"
  ::  would be parsed into %foo mapped to
  ::  ~[["QUX" m]]
  ::  where m is a map with key "BAR" and value "BAZ"
  ::
  =|  acc=(jar valarm-tag [tape (map tape tape)])
  =/  rest-jar=(jar valarm-tag [tape (map tape tape)])
      |-
      ?~  rest
        acc
      =/  res  (process-line i.rest valarm-tag)
      ?~  res
        $(rest t.rest)
      =/  [k=valarm-tag v=[tape (map tape tape)]]  u.res
      $(rest t.rest, acc (~(add ja acc) k v))
  %-  some
  ?-  u.action
    %audio  [u.action (parse-audio rest-jar)]
    %display  [u.action (parse-display rest-jar)]
    %email  [u.action (parse-email rest-jar)]
  ==
  |%
  ::  $valarm-tag:  types of tags in valarms
  +$  valarm-tag
    $?
      %trigger
      %duration
      %repeat
      %attach
      %description
      %summary
      %attendee
    ==
  ::
  ++  parse-audio
    |=  j=(jar valarm-tag [tape (map tape tape)])
    ^-  valarm-audio
    :+
    (parse-trigger j)
    (parse-duration-repeat j)
    (unit-tape-from-tag j %attach)
  ::
  ++  parse-display
    |=  j=(jar valarm-tag [tape (map tape tape)])
    ^-  valarm-display
    :+
    (parse-trigger j)
    (need (unit-tape-from-tag j %description))
    (parse-duration-repeat j)
  ::
  ++  parse-email
    |=  j=(jar valarm-tag [tape (map tape tape)])
    ^-  valarm-email
    =/  attendees=(list tape)
        %+  turn
          (~(get ja j) %attendee)
        |=  [t=tape =(map tape tape)]
        t
    ::  email valarms must have at least one attendee
    ::
    ?~  attendees
      !!
    =/  attachments=(list tape)
        %+  turn
          (~(get ja j) %attach)
        |=  [t=tape =(map tape tape)]
        t
    :*
      (parse-trigger j)
      (need (unit-tape-from-tag j %description))
      (need (unit-tape-from-tag j %summary))
      attendees
      attachments
    ==
  ::  +unit-tape-from-tag:  produces the tape for a given tag,
  ::  asserting that it appears 0 or 1 times
  ::
  ++  unit-tape-from-tag
    |=
    [j=(jar valarm-tag [tape (map tape tape)]) tag=valarm-tag]
    ^-  (unit tape)
    =/  tag-list  (~(get ja j) tag)
    ?>  (lth (lent tag-list) 2) :: 0 or 1 of our tag
    ?~  tag-list
      ~
    `-:i.tag-list
  ::
  ++  parse-trigger
    |=  j=(jar valarm-tag [tape (map tape tape)])
    ^-  valarm-trigger
    =/  triggers  (~(get ja j) %trigger)
    ?>  =((lent triggers) 1) ::  exclusive tag
    =/  [t=tape props=(map tape tape)]  (snag 0 triggers)
    =/  value-unit=(unit tape)  (~(get by props) "VALUE")
    ::  if we don't have a "VALUE" or it's duration,
    ::  then we have a duration to parse.
    ::
    ?:  |(?=($~ value-unit) =(u.value-unit "DURATION"))
      =/  related-unit=(unit tape)  (~(get by props) "RELATED")
      =/  related=valarm-related
          ::  if we don't have a "RELATED" it defaults to start
          ::
          ?:  |(?=($~ related-unit) =(u.related-unit "START"))
            %start
          ?>  =(u.related-unit "END")
          %end
      [%rel related (parse-duration t)]
    ::  otherwise, the value must be date-time
    ::
    ?>  =(u.value-unit "DATE-TIME")
    [%abs (parse-datetime-value t)]
  ::
  ++  parse-duration-repeat
    |=  j=(jar valarm-tag [tape (map tape tape)])
    ^-  (unit valarm-duration-repeat)
    =/  duration-list=(list [tape (map tape tape)])
        (~(get ja j) %duration)
    =/  repeat-list=(list [tape (map tape tape)])
        (~(get ja j) %repeat)
    ?:  &(?=($~ duration-list) ?=($~ repeat-list))
      ::  duration and repeat not specified
      ::
      ~
    ::  if only one of duration or repeat specified, error
    ?:  |(?=($~ duration-list) ?=($~ repeat-list))
      !!
    ::  both specified, now assert that they're only
    ::  specified once
    ::
    ?>  =((lent duration-list) 1)
    ?>  =((lent repeat-list) 1)
    =/  repeat=@  (scan -:i.repeat-list (cook from-digits digits))
    =/  [s=? d=@dr]  (parse-duration -:i.duration-list)
    ::  must have positive duration
    ?>  s
    `[d repeat]
  --
::
++  parse-vevent
  =<
  |=  w=wall
  ^-  vevent
  =|  v=vevent
  =|  rt=required-tags
  =|  ut=unique-tags
  |-
  ::  if we're out of lines, produce v.
  ::
  ?~  w
    ::  now check if all fields in rt are true - if not, we are missing
    ::  a required field and we should error
    ::
    ?>  &(dtstamp.rt uid.rt dtstart.rt dtend-duration.rt)
    v
  =/  res  (process-line i.w vevent-tag)
  ?~  res
    ::  tag was invalid, skip line
    ::
    $(w t.w)
  =/  [tag=vevent-tag tok=tape props=(map tape tape)]
      u.res
  =/  parser
  ?+  tag  no-parse
    %dtstamp  parse-dtstamp
    %uid  parse-uid
    %dtstart  parse-dtstart
    %dtend  parse-dtend
    %duration  parse-vevent-duration
    %organizer  parse-organizer
    %categories  parse-categories
    %class  parse-class
    %comment  parse-comment
    %description  parse-description
    %summary  parse-summary
    %geo  parse-geo
    %location  parse-location
    %status  parse-status
    %begin  parse-subcomponent
    %rrule  parse-rrule
    %rdate  parse-rdate
    %exdate  parse-exdate
    %created  parse-created
    %last-modified  parse-last-modified
    %sequence  parse-sequence
    %transp  parse-transparency
    %priority  parse-priority
    %url  parse-url
  ==
  ::  call parser with second token (data) and props without the tag,
  ::  along with our vevent and required-tags
  ::
  =/  res=[v=vevent rt=required-tags ut=unique-tags l=wall]
      (parser tok t.w props v rt ut)
  $(w l.res, v v.res, rt rt.res, ut ut.res)
  |%
  ::  $required-tags:  tags we expect to see exactly once in a vevent
  ::
  +$  required-tags
    $:
      dtstamp=galf
      uid=galf
      dtstart=galf
      ::  either dtend or duration is required
      ::
      dtend-duration=galf
    ==
  ::  $unique-tags: tags we expect to see no more than once in a vevent
  ::
  +$  unique-tags
    $:
      class=galf
      created=galf
      description=galf
      geo=galf
      last-modified=galf
      location=galf
      organizer=galf
      priority=galf
      sequence=galf
      status=galf
      summary=galf
      transp=galf
      url=galf
      recurrence-id=galf
      rrule=galf
    ==
  ::  $vevent-tag:  possible properties to parse for a vevent
  ::
  ::    comments reflect the field in vevent they refer to if the name
  ::    doesn't match the tag itself
  ::
  +$  vevent-tag
    $?
      %dtstamp
      %uid
      %dtstart
      %dtend ::  end
      %duration ::  end
      %organizer
      %categories
      %class ::  classification
      %comment
      %description
      %summary
      %geo
      %location
      %status
      %begin ::  subcomponent, alarms
      %rrule
      %rdate
      %exdate
      %created
      %last-modified
      %sequence
      %transp
      %priority
      %url
      ::  unsupported (as of now)
      ::
      %recurrence-id
      %attach
      %attendee
      %contact
      %rstatus
      %related
      %resources
    ==
  ::  +no-parse:  used for tags we don't support
  ::
  ++  no-parse
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    :^(v rt ut rest)
  ::
  ++  parse-dtstamp
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  dtstamp.rt
    :^
    v(dtstamp (parse-datetime-value t))
    rt(dtstamp &)
    ut
    rest
  ::
  ++  parse-dtstart
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  dtstart.rt
    :^
    v(dtstart (parse-date-or-datetime t))
    rt(dtstart &)
    ut
    rest
  ::
  ++  parse-dtend
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  dtend-duration.rt
    :^
    v(end [%dtend (parse-date-or-datetime t)])
    rt(dtend-duration &)
    ut
    rest
  ::
  ++  parse-vevent-duration
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  dtend-duration.rt
    =/  [sign=? d=@dr]  (parse-duration t)
    ::  assert positive duration for vevent
    ::
    ?>  sign
    :^
    v(end [%duration d])
    rt(dtend-duration &)
    ut
    rest
  ::
  ++  parse-uid
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  uid.rt
    :^
    v(uid (crip t))
    rt(uid &)
    ut
    rest
  ::
  ++  parse-organizer
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  organizer.ut
    :^
    v(organizer `t)
    rt
    ut(organizer &)
    rest
  ::
  ++  parse-categories
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    =/  cats=wall  (split t com)
    :^(v(categories (weld cats categories.v)) rt ut rest)
  ::
  ++  parse-class
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  class.ut
    =/  class  (^:(event-class) (crip (cass t)))
    :^
    v(classification `class)
    rt
    ut(class &)
    rest
  ::
  ++  parse-comment
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    :^(v(comment [t comment.v]) rt ut rest)
  ::
  ++  parse-description
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  description.ut
    :^
    v(description `t)
    rt
    ut(description &)
    rest
  ::
  ++  parse-summary
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  summary.ut
    :^
    v(summary `t)
    rt
    ut(summary &)
    rest
  ::
  ++  parse-geo
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  geo.ut
    ::  we expect two semicolon separated float values
    ::
    =/  tokens=(list tape)  (split t mic)
    ?>  =((lent tokens) 2)
    =/  ll=latlon
        :-
        (parse-float (snag 0 tokens))
        (parse-float (snag 1 tokens))
    :^
    v(geo `ll)
    rt
    ut(geo &)
    rest
  ::
  ++  parse-location
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  location.ut
    :^
    v(location `t)
    rt
    ut(location &)
    rest
  ::
  ++  parse-status
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  status.ut
    =/  status  (^:(event-status) (crip (cass t)))
    :^
    v(status `status)
    rt
    ut(status &)
    rest
  ::
  ++  parse-subcomponent
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ::  vevents only support nested valarm components
    ::
    ?>  =(t "VALARM")
    =/  end-idx=(unit @)  (find ~["END:VALARM"] rest)
    ::  if subcomponent not properly closed, error
    ::
    ?~  end-idx
      !!
    =/  alarm-lines=wall  (scag u.end-idx rest)
    =/  continuation=wall  (slag +(u.end-idx) rest)
    =/  alarm=(unit valarm)  (parse-valarm alarm-lines)
    ?~  alarm
      :^(v rt ut continuation)
    :^
    v(alarms [u.alarm alarms.v])
    rt
    ut
    continuation
  ::
  ++  parse-rrule
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  rrule.ut
    :^
    v(rrule `(parse-recur t))
    rt
    ut(rrule &)
    rest
  ::
  ++  parse-rdate
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    :^
    v(rdate (weld rdate.v (parse-rdate-values t props)))
    rt
    ut
    rest
  ::
  ++  parse-exdate
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    =/  date-strings=(list tape)  (split t com)
    =/  dates=(list ical-time)
        (turn date-strings parse-date-or-datetime)
    :^
    v(exdate (weld exdate.v dates))
    rt
    ut
    rest
  ::
  ++  parse-created
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  created.ut
    =/  dt  (parse-datetime-value t)
    ?>  utc.dt
    :^
    v(created `d.dt)
    rt
    ut(created &)
    rest
  ::
  ++  parse-last-modified
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  last-modified.ut
    =/  dt  (parse-datetime-value t)
    ?>  utc.dt
    :^
    v(last-modified `d.dt)
    rt
    ut(last-modified &)
    rest
  ::
  ++  parse-sequence
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  sequence.ut
    :^
    v(sequence (from-digits (scan t digits)))
    rt
    ut(sequence &)
    rest
  ::
  ++  parse-transparency
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  transp.ut
    :^
    v(transparency (^:(vevent-transparency) (crip (cass t))))
    rt
    ut(transp &)
    rest
  ::
  ++  parse-priority
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  priority.ut
    =/  prio=@  (from-digits (scan t digits))
    ?>  (in-between [0 9] prio)
    :^
    v(priority prio)
    rt
    ut(priority &)
    rest
  ::
  ++  parse-url
    |=  [t=tape rest=wall props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
    ^-  [vevent required-tags unique-tags wall]
    ?<  url.ut
    :^
    v(url `t)
    rt
    ut(url &)
    rest
  --
::  +read-file:  get lines of a file in order
::
++  read-file
  |=  pax=path
  ^-  wall
  ::  request lines from clay
  ::
  =/  lines=tang  (pretty-file .^(noun %cx pax))
  =/  tapes=wall
  %+  turn
    lines
  |=(t=tank ~(ram re t))
  ::  now drop last item from list as it's a sig
  ::
  (oust [(dec (lent tapes)) 1] tapes)
::  +unfold-lines:  "unfold" lines, as per the rfc.
::
::    CRLF and then a whitespace signifies a fold, so we
::    join together lines separated by this with the separations
::    removed
::
++  unfold-lines
  =<
  |=  lines=wall
  ^-  wall
  ?~  lines
    ~
  =/  first=tape  i.lines
  ?~  t.lines
    [first ~]
  =/  second=tape  i.t.lines
  =/  rest=wall  t.t.lines
  =|  acc=wall
  |-
  =/  unfolded=(unit tape)  (unfold first second)
  =/  [newfirst=tape newacc=wall]
      ?~  unfolded
        [second [first acc]]
      [u.unfolded acc]
  ?~  rest
    (flop [newfirst newacc])
  $(acc newacc, rest t.rest, first newfirst, second i.rest)
  |%
  ::  whitespace rule, ace for ascii 32 (space), '\09' for tab
  ::
  ++  wsp  ;~(pose ace (jest '\09'))
  ::  See if two lines should be unfolded. Produces a unit tape
  ::  which contains the unfolded line if it was possible to unfold.
  ::  we assume that the first tape ended in a newline.
  ::
  ++  unfold
    |=  [first=tape second=tape]
    ^-  (unit tape)
    =/  n=@  (dec (lent first))
    =/  res  (rust second ;~(plug wsp (star next)))
    ::  now check for failures
    ::
    ::  second line doesn't start with a whitespace
    ::
    ?~  res
      ~
    ::  first line doesn't end in carriage return
    ::
    ?:  !=((snag n first) '\0d')
      ~
    ::  trim carriage return
    ::
    =/  f-prefix=tape  (scag n first)
    ::  trim whitespace
    ::
    =/  s-tail=tape  +:u.res
    `(weld f-prefix s-tail)
  --
::
++  parse-vcalendar
  =<
  |=  lines=wall
  ^-  vcalendar
  =/  n=@  (lent lines)
  ?>  (gte n 2)
  ?>  =((snag 0 lines) "BEGIN:VCALENDAR")
  ?>  =((snag (dec n) lines) "END:VCALENDAR")
  ?~  lines
    !!
  ::  get rid of vcalendar begin/end
  ::
  =/  trimmed-lines=wall
      (oust [(sub n 2) 1] t.lines)
  =|  cal=vcalendar
  =|  rt=required-tags
  |-
  ?~  trimmed-lines
    ?>  &(prodid.rt version.rt)
    cal
  =+  res=(process-line i.trimmed-lines vcal-tag)
  ?~  res
    $(trimmed-lines t.trimmed-lines)
  =/  [tag=vcal-tag data=tape props=(map tape tape)]  u.res
  =/  parser
      ?-  tag
        %version  parse-version
        %prodid  parse-prodid
        %begin  parse-subcomponent
      ==
  =/  [newc=vcalendar nrt=required-tags rest=wall]
      (parser data t.trimmed-lines cal rt)
  $(cal newc, rt nrt, trimmed-lines rest)
  |%
  ::  $required-tags:  tags we expect to see exactly once in a vcalendar
  ::
  +$  required-tags
    $:
      prodid=galf
      version=galf
    ==
  ::  $vcal-tag:  tags present in vcalendar that we parse
  ::
  +$  vcal-tag
    $?
      %version
      %prodid
      %begin
    ==
  ::
  ++  parse-prodid
    |=  [t=tape w=wall c=vcalendar rt=required-tags]
    ^-  [vcalendar required-tags wall]
    ?<  prodid.rt
    :+
    c(prodid t)
    rt(prodid &)
    w
  ::
  ++  parse-version
    |=  [t=tape w=wall c=vcalendar rt=required-tags]
    ^-  [vcalendar required-tags wall]
    ?<  version.rt
    :+
    c(version t)
    rt(version &)
    w
  ::
  ++  parse-subcomponent
    |=  [t=tape w=wall c=vcalendar rt=required-tags]
    ^-  [vcalendar required-tags wall]
    ::  find end of subcomponent and separate w into
    ::  lines containing the subcomponent and the continuation
    ::  to keep parsing
    ::
    =/  end-idx=@  (need (find ~[(weld "END:" t)] w))
    =/  rest=wall  (slag +(end-idx) w)
    =/  subcomponent-lines=wall  (scag end-idx w)
    =/  new-calendar=vcalendar
        ::  now check to see if we have a parse-able subcomponent,
        ::  updating the calendar appropriately. non parse-able
        ::  subcomponents are VTODO, VJOURNAL, and VFREEBUSY
        ::
        =/  tag=term  (crip (cass t))
        ?+  tag  c
          %vevent     =/  event=vevent  (parse-vevent subcomponent-lines)
                      c(events [event events.c])
          %vtimezone  =/  timezone=vtimezone
                          (need (parse-vtimezone subcomponent-lines))
                      c(timezones (~(put by timezones.c) id.timezone timezone))
        ==
    [new-calendar rt rest]
  --
::  +calendar-from-file:  builds calendar from specified file
::
++  calendar-from-file
  |=  pax=path
  ^-  vcalendar
  =/  lines=wall
      %+  turn
        (unfold-lines (read-file pax))
      ::  now trim trailing carriage-returns
      ::
      |=  t=tape
      =/  n=@  (dec (lent t))
      ?:  =((snag n t) '\0d')
        (scag n t)
      t
  (parse-vcalendar lines)
--
