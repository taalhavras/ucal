/+  pretty-file, ucalendar-components, ucalendar-calendar
=,  [ucalendar-components ucalendar-calendar]
::  Core for parsing .ics files containing VEVENTs and VALARMs
|%
::  reverse flag type, defaults to false. used for more
::  convenient initialization with =| for some types
++  galf  $~(| ?)
::  splits a line into tag, data, and properties
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
        %+  turn  (slag 1 props)
        |=  tok=tape
        =/  components=(list tape)  (split tok tis)
        ?>  =((lent components) 2)
        [(snag 0 components) (snag 1 components)]
    `[u.tag (snag 1 tokens) (~(gas by props-map) props-list)]
::  checks if lower <= x <= higher
++  in-between
    |=  [[lower=@ higher=@] x=@]
    ^-  flag
    ?&((lte lower x) (gte higher x))
::  utilities for validating parts of times.
::  bake applies the @ mold to the arg, making these dry gates
++  valid-month  (bake (cury in-between [0 12]) @)
++  valid-hour  (bake (cury in-between [0 23]) @)
++  valid-min  (bake (cury in-between [0 59]) @)
++  valid-sec  (bake (cury in-between [0 60]) @) ::  60 for leap seconds
++  valid-monthday  (bake (cury in-between [1 31]) @)
++  valid-yearday  (bake (cury in-between [1 366]) @) ::  366 for leap years
++  valid-weeknum  (bake (cury in-between [1 53]) @)
::  rule builder for matching 0 or 1 time. regex '?'
::  "wut" as a name is already taken, so now we have this
++  whut
    |*(rul=rule (stun [0 1] rul))
::  rule for common digit groupings
++  digits  (plus dit)
++  two-dit  ;~(plug dit dit)
++  four-dit  ;~(plug dit dit dit dit)
::  split input tape on delim rule, return list of tapes.
::  if delimiter isn't present, then return list containing just
::  the original tape.
++  split
    |*  [t=tape delim=rule]
    ^-  (list tape)
    ::  rule to match "words" or non-delim strings
    =/  w  (star ;~(less delim next))
    %+  fall
      (rust t (more delim w))
    ~[t]
::  splits a tape on the first instance of a delimiter.
::  if delimiter isn't present, then return list containing just
::  the original tape.
++  split-first
    |*  [t=tape delim=rule]
    ^-  (list tape)
    =/  res  (rust t ;~(plug (star ;~(less delim next)) delim (star next)))
    ?~  res
      ~[t]
    ~[-:u.res +>:u.res]
::  converts a cell of two digits to a single atom (tens and ones place)
++  from-two-digit  |=  [a=@ b=@]  (add (mul 10 a) b)
::  converts a list of digits to a single atom
++  from-digits
    |=  l=(list @)
    =|  acc=@
    =/  m=@  (pow 10 (dec (lent l)))
    |-
    ?~  l
      acc
    $(acc (add acc (mul i.l m)), m (div m 10), l t.l)
::  parses a 'recur' data type from a tape
++  parse-recur
    =<
    |=  t=tape
    ^-  rrule
    ::  split on semicolon
    =/  tokens=(list tape)  (split t mic)
    =/  parts=(map tape tape)  (produce-parts-map tokens)
    ::  freq is the only required component here
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
    +$  validator  $-(@ flag)
    ::  produce map of all the parts of a recurrence rule mapped to
    ::  their values. all parts MUST be unique
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
        ?~  (~(get by acc) key)
          $(l t.l, acc (~(put by acc) key (snag 1 tokens)))
        !!
    ++  parse-freq
        |=  parts=(map tape tape)
        ^-  rrule-freq
        (^:(rrule-freq) (crip (cass (~(got by parts) "FREQ"))))
    ++  parse-until
        |=  parts=(map tape tape)
        ^-  (unit ical-time)
        =/  token=(unit tape)  (~(get by parts) "UNTIL")
        ?~  token
          ~
        `(parse-date-or-datetime u.token)
    ++  parse-count
        |=  parts=(map tape tape)
        ^-  (unit @)
        =/  token=(unit tape)  (~(get by parts) "COUNT")
        ?~  token
          ~
        %-  some
        %+  scan
        u.token
        (cook from-digits digits)
    ++  parse-interval
        |=  parts=(map tape tape)
        ^-  @
        =/  token=(unit tape)  (~(get by parts) "INTERVAL")
        ?~  token
          1 ::  default value for interval is 1
        %+  scan
        u.token
        (cook from-digits digits)
    ::  parses and validates lists of two-digit atoms from a tape
    ::  if the validator fails, throw an error
    ++  parse-and-validate-two-digits
        |=  [t=tape v=validator]
        ^-  (list @)
        =/  tokens=(list tape)  (split t com)
        %+  turn  tokens
        |=  tok=tape
            ^-  @
            %+  scan  tok
            %+  cook
            |=  digits=[@ @]
                ^-  @
                =/  res=@  (from-two-digit digits)
                ?>  (v res)
                res
            two-dit
    ++  parse-bysecond
        |=  parts=(map tape tape)
        ^-  (list @)
        =/  res=(unit tape)  (~(get by parts) "BYSECOND")
        ?~  res
          ~
        (parse-and-validate-two-digits u.res valid-sec)
    ++  parse-byminute
        |=  parts=(map tape tape)
        ^-  (list @)
        =/  res=(unit tape)  (~(get by parts) "BYMINUTE")
        ?~  res
          ~
        (parse-and-validate-two-digits u.res valid-min)
    ++  parse-byhour
        |=  parts=(map tape tape)
        ^-  (list @)
        =/  res=(unit tape)  (~(get by parts) "BYHOUR")
        ?~  res
          ~
        (parse-and-validate-two-digits u.res valid-hour)
    ::  parses and validates a signed number
    ++  parse-and-validate-sign-and-atom
        |=  [t=tape v=validator]
        ^-  (list [? @])
        =/  tokens=(list tape)  (split t com)
        %+  turn  tokens
        |=  tok=tape
            ^-  [? @]
            =/  res=[? a=@]
            %+  scan  tok
            ;~
              plug
              %+  cook
                |=(x=tape !=(x "-")) ::  %.y if we don't have '-', %.n otherwise
                (whut ;~(pose lus hep)) :: optional sign
              (cook from-digits digits)
            ==
            ?>  (v a.res)
            res
    ++  parse-byweekday
        |=  parts=(map tape tape)
        ^-  (list rrule-weekdaynum)
        =/  res=(unit tape)  (~(get by parts) "BYDAY")
        ?~  res
          ~
        ::  Split on comma to get each weekdaynum. We will then need to
        ::  parse each token individually...
        =/  tokens=(list tape)  (split u.res com)
        %+  turn  tokens
        |=  t=tape
            =/  res
                %+  scan  t
                ;~
                  plug
                  %-  whut
                  ;~
                    plug
                    %+  cook
                    |=(x=tape !=(x "-")) ::  %.y if we don't have '-', %.n otherwise
                    (whut ;~(pose lus hep)) :: optional sign
                    (cook from-digits digits)
                  ==
                  ;~(plug hig hig)  ::  two uppercase characters
                ==
            ::  day should always be present
            =/  day=rrule-day
                (^:(rrule-day) (crip (cass ~[+<:res +>:res])))
            ::  now, we must go through the various cases
            =/  hd  -:res
            ?~  hd
              ::  we didn't have a sign or a number
              :-(day ~)
            =/  num=@  -<+:res
            ?>  (valid-weeknum num)
            =/  sign=flag  -<-:res
            :-(day `[sign num])
    ++  parse-bymonthday
        |=  parts=(map tape tape)
        ^-  (list rrule-monthdaynum)
        =/  res=(unit tape)  (~(get by parts) "BYMONTHDAY")
        ?~  res
          ~
        %+  parse-and-validate-sign-and-atom  u.res
        valid-monthday
    ++  parse-byyearday
        |=  parts=(map tape tape)
        ^-  (list rrule-yeardaynum)
        =/  res=(unit tape)  (~(get by parts) "BYYEARDAY")
        ?~  res
          ~
        %+  parse-and-validate-sign-and-atom  u.res
        valid-yearday
    ++  parse-byweek
        |=  parts=(map tape tape)
        ^-  (list rrule-weeknum)
        =/  res=(unit tape)  (~(get by parts) "BYWEEKNO")
        ?~  res
          ~
        %+  parse-and-validate-sign-and-atom  u.res
        valid-weeknum
    ++  parse-bymonth
        |=  parts=(map tape tape)
        ^-  (list rrule-monthnum)
        =/  res=(unit tape)  (~(get by parts) "BYMONTH")
        ?~  res
          ~
        %+  parse-and-validate-sign-and-atom  u.res
        valid-month
    ++  parse-bysetpos
        |=  parts=(map tape tape)
        ^-  (list rrule-monthnum)
        =/  res=(unit tape)  (~(get by parts) "BYSETPOS")
        ?~  res
          ~
        %+  parse-and-validate-sign-and-atom  u.res
        valid-yearday ::  also yearday
    ++  parse-weekstart
        |=  parts=(map tape tape)
        ^-  rrule-day
        =/  res=(unit tape)  (~(get by parts) "WKST")
        ?~  res
          %mo ::  default is monday
        (^:(rrule-day) (crip (cass u.res)))
    --
::  parses a signed floating point from a string
++  parse-float
    |=  t=tape
    ^-  dn
    =/  rul
        ;~
          plug
          %+  cook
            |=(x=tape !=(x "-")) ::  %.y if we don't have '-', %.n otherwise
            (whut ;~(pose lus hep)) :: optional sign
          digits
          (whut ;~(plug dot digits))
        ==
    =/  res  (scan t rul)
    =/  d=dn  [%d s=-:res e=--0 a=0]
    ::  get number before decimal point
    =/  before-decimal=@  (from-digits `(list @)`+<:res)
    =/  decimal  +>:res ::  part after decimal point (includes decimal)
    ?~  decimal
      [%d s=-:res e=--0 a=before-decimal]
    =/  decimal-digits=(list @)  `(list @)`->:decimal
    ::  so now we want to multiply num by 10^(lent decimal-digits) and
    ::  set our exponent (e) in d to -(lent decimal-digits).
    =/  exponent=@  (lent decimal-digits)
    =/  mantissa=@
        %+  add
        (mul before-decimal (pow 10 exponent))
        (from-digits decimal-digits)
    ::  signed representation is one less than twice absolute value
    =/  neg-exponent=@s  (dec (mul 2 exponent))
    [%d s=-:res e=neg-exponent a=mantissa]
::  parses a period
++  parse-period
    |=  t=tape
    ^-  period
    ::  split on '/'. first token is a date-time, second will either be
    ::  date-time or duration. the duration MUST BE POSITIVE
    =/  tokens=(list tape)  (split t fas)
    ?>  =((lent tokens) 2)
    =/  begin=ical-datetime  (parse-datetime-value (snag 0 tokens))
    =/  second=tape  (snag 1 tokens)
    ::  matches prefix of duration
    =/  dur-rul  ;~(plug ;~(pose lus hep) (jest 'P'))
    ?:  =((rust second ;~(pfix dur-rul (star next))) ~)
      ::  we have a date-time for the second
      [%explicit begin (parse-datetime-value second)]
    =/  [sign=? dur=tarp]  (parse-duration second)
    ?>  sign ::  duration must be positive
    [%start begin dur]
::  takes a tape representing a duration, produces a cell of tarp and a
::  flag representing whether the duration is positive or negative,
::  %.y for positive and %.n for negative
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
    %+  scan  t
    ;~
      plug
      %+  cook
      |=  x=tape
          !=(x "-")  ::  produce %.y if we don't have '-', %.n otherwise
      (whut ;~(pose lus hep)) :: optional sign
      (jest 'P')
      ;~
        pose
        dur-time
        dur-date
        dur-week
      ==
    ==
    [f.res tar.res]
    |%
    ++  cook-week
        |=  [digits=(list @) =cord]
        ^-  tarp
        =|  tar=tarp
        tar(d (mul 7 (from-digits digits)))
    ++  cook-sec
        |=  [digits=(list @) =cord]
        ^-  tarp
        =|  tar=tarp
        tar(s (from-digits digits))
    ++  cook-min
        |=  [digits=(list @) =cord sec=*]
        ^-  tarp
        =|  tar=tarp
        =/  minutes=@  (from-digits digits)
        ?~  sec
          tar(m minutes)
        ::  we have seconds to parse
        =/  secs=tarp  (^:(tarp) -:sec)
        secs(m minutes)
    ++  cook-hour
        |=  [digits=(list @) =cord min=*]
        ^-  tarp
        =|  tar=tarp
        =/  hours=@  (from-digits digits)
        ?~  min
          tar(h hours)
        ::  parse minutes
        =/  mins=tarp  (^:(tarp) -:min)
        mins(h hours)
    ++  cook-day
        |=  [digits=(list @) =cord]
        ^-  tarp
        =|  tar=tarp
        tar(d (from-digits digits))
    ++  cook-time
        |=  [=cord t=tarp]
        ^-  tarp
        t
    ++  cook-date
        |=  [day=tarp time=*]
        ^-  tarp
        ::  if we have no time, just use day value, otherwise
        ::  combine both
        ?~  time
          day
        =/  timetarp=tarp  (^:(tarp) -:time)
        timetarp(d d.day)
    --
::  used to parse tapes that are either dates or datetimes
++  parse-date-or-datetime
    |=  t=tape
    ^-  ical-time
    ::  check if length of tape is 8. If it is, dtstamp is a date.
    ::  otherwise, it's a date-time
    ?:  =((lent t) 8)
      (parse-date-value t)
    (parse-datetime-value t)
::  parse an ics date value - a tape of the form "YYYYMMDD"
++  parse-date-value
    |=  t=tape
    ^-  ical-date
    =|  d=date
    ::  parse tape into [[Y Y Y Y] [M M] [D D]]
    =/  res  (scan t ;~(plug four-dit two-dit two-dit))
    =/  day=@  (from-two-digit +>:res)
    =/  month=@  (from-two-digit +<:res)
    =/  yc=[a=@ b=@ c=@ d=@]  -:res
    ::  computes 1000*a + 100*b + 10*c + d
    =/  year=@
        %+  add
        (mul 100 (from-two-digit [a.yc b.yc]))
        (from-two-digit [c.yc d.yc])
    [%date d(y year, m month, d.t day)]
::  parses an ics datetime, formatted as: YYYYMMDD followed by a 'T' and
::  then the time. time is formatted as HHMMSS for hour, minute, and second.
::  optionally, there may also be a 'Z' at the end, signifying UTC time
++  parse-datetime-value
    |=  t=tape
    ^-  ical-datetime
    ::  expect two tokens here
    =/  tokens=(list tape)  (split t (jest 'T'))
    =/  d=ical-date  (parse-date-value (snag 0 tokens))
    ::  TODO validate these digits? special rules with shims?
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
    =/  minutes=@  (from-two-digit +<:res)
    =/  seconds=@  (from-two-digit +>-:res)
    =/  utc=?  =(+>+:res "Z")
    [%date-time d.d(h.t hours, m.t minutes, s.t seconds) utc]
++  parse-valarm
    =<
    |=  w=wall
    ^-  (unit valarm)
    ::  Split lines into action prop and others. Once we have
    ::  the action prop, we can call the specific parser for
    ::  the particular type of valarm.
    =/  action-rul
        ;~(plug (jest 'ACTION') (star ;~(less col next)) col (star next))
    =/  [actions=wall rest=wall]
        %+  skid  w
        |=  t=tape
        ^-  flag
        =/  res  (rust t action-rul)
        !=(res ~)
    ?>  =((lent actions) 1) ::  action is a unique tag
    =/  action-prop=tape  (snag 1 (split (snag 0 actions) col))
    =/  action=(unit valarm-action)
        ((soft valarm-action) (crip (cass action-prop)))
    ?~  action
      ~
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
      ::  It's cool that action can just be used here as the tag.
      %audio  [u.action (parse-audio rest-jar)]
      %display  [u.action (parse-display rest-jar)]
      %email  [u.action (parse-email rest-jar)]
    ==
    |%
    ::  largest set of required tags, don't check all in all cases
    +$  required-tags  $:
        trigger=galf
        duration=galf
        repeat=galf
        attach=galf
        description=galf
        summary=galf
        attendee=galf
        ==
    +$  valarm-tag  $?
        %trigger
        %duration
        %repeat
        %attach
        %description
        %summary
        %attendee
        ==
    ++  parse-audio
        |=  j=(jar valarm-tag [tape (map tape tape)])
        ^-  valarm-audio
        :+
        (parse-trigger j)
        (parse-duration-repeat j)
        (unit-tape-from-tag j %attach)
    ++  parse-display
        |=  j=(jar valarm-tag [tape (map tape tape)])
        ^-  valarm-display
        :+
        (parse-trigger j)
        (need (unit-tape-from-tag j %description))
        (parse-duration-repeat j)
    ++  parse-email
        |=  j=(jar valarm-tag [tape (map tape tape)])
        ^-  valarm-email
        =/  attendees=(list tape)
            %+  turn
            (~(get ja j) %attendee)
            |=  [t=tape =(map tape tape)]
            t
        ?~  attendees
          !!  ::  must have at least one attendee
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
    ::  produces the tape for a given tag, asserting that
    ::  it appears 0 or 1 times
    ++  unit-tape-from-tag
        |=
        [j=(jar valarm-tag [tape (map tape tape)]) tag=valarm-tag]
        ^-  (unit tape)
        =/  tag-list  (~(get ja j) tag)
        ?>  (lth (lent tag-list) 2) :: 0 or 1 of our tag
        ?~  tag-list
          ~
        `-:i.tag-list
    ++  parse-trigger
        |=  j=(jar valarm-tag [tape (map tape tape)])
        ^-  valarm-trigger
        =/  triggers  (~(get ja j) %trigger)
        ?>  =((lent triggers) 1) ::  exclusive tag
        =/  [t=tape props=(map tape tape)]  (snag 0 triggers)
        =/  value-unit=(unit tape)  (~(get by props) "VALUE")
        ::  if we don't have a "VALUE" or it's duration,
        ::  then we have a duration to parse.
        ?:  |(?=($~ value-unit) =(u.value-unit "DURATION"))
          =/  related-unit=(unit tape)  (~(get by props) "RELATED")
          =/  related=valarm-related
              ::  if we don't have a "RELATED" it defaults to start
              ?:  |(?=($~ related-unit) =(u.related-unit "START"))
                %start
              ?>  =(u.related-unit "END")
              %end
          [%rel related (parse-duration t)]
        ::  otherwise, the value must be date-time
        ?>  =(u.value-unit "DATE-TIME")
        [%abs (parse-datetime-value t)]
    ++  parse-duration-repeat
        |=  j=(jar valarm-tag [tape (map tape tape)])
        ^-  (unit valarm-duration-repeat)
        =/  duration-list=(list [tape (map tape tape)])
            (~(get ja j) %duration)
        =/  repeat-list=(list [tape (map tape tape)])
            (~(get ja j) %repeat)
        ?:  &(?=($~ duration-list) ?=($~ repeat-list))
          ::  duration and repeat not specified
          ~
        ?:  |(?=($~ duration-list) ?=($~ repeat-list))
          ::  one of duration or repeat specified, error
          !!
        ::  both specified, now assert that they're only
        ::  specified once
        ?>  =((lent duration-list) 1)
        ?>  =((lent repeat-list) 1)
        =/  repeat=@  (scan -:i.repeat-list (cook from-digits digits))
        =/  duration=[s=? t=tarp]  (parse-duration -:i.duration-list)
        ?>  s.duration  ::  must have positive duration
        `[t.duration repeat]
    --
++  parse-vevent
    =<
    |=  w=wall ::  (list tape)
    ^-  vevent
    =|  v=vevent
    =|  rt=required-tags
    =|  ut=unique-tags
    |-
    ::  if we're out of lines, produce v.
    ?~  w
      ::  now check if all fields in rt are true - if not, we are missing
      ::  a required field
      ?:  &(dtstamp.rt uid.rt dtstart.rt dtend-duration.rt)
        v
      !!
    =/  res  (process-line i.w vevent-tag)
    ?~  res
      ::  tag was invalid, skip line
      $(w t.w)
    =/  [tag=vevent-tag tok=tape props=(map tape tape)]
        u.res
    ::  begin is a special case.
    ::  find ending index, snip out relevant lines for parse-subcomponent and
    ::  advance w past those lines.
    ::  FIXME I guess the most general approach is to thread t.w
    ::  through every function and have them all return the continuation from
    ::  whatever they parsed - this would let us include %begin in the big
    ::  wutlus below. However, this would require changing every one of these
    ::  parsers, which seems odd (since only nested subcomponents will consume
    ::  more than one line from w). Not really sure which way to go on this one.
    ?:  =(tag %begin)
      =/  end-idx=(unit @)  (find ~[(weld "END:" tok)] t.w)
      ?~  end-idx
        ::  subcomponent not properly closed
        !!
      =/  subcomponent-lines=wall  (swag [0 u.end-idx] t.w)
      =/  res=[v=vevent rt=required-tags ut=unique-tags]
          (parse-subcomponent subcomponent-lines tok props v rt ut)
      $(v v.res, rt rt.res, ut ut.res, w (slag +(u.end-idx) t.w))
    =/  parser=parser-fn
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
      ::  %begin  this special case is handled above
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
    =/  res=[v=vevent rt=required-tags ut=unique-tags]
        (parser tok props v rt ut)
    $(w t.w, v v.res, rt rt.res, ut ut.res)
    |%
    ::  tags we expect to see exactly once (required)
    ::  these can be flags, unless there are tags we require at least
    ::  once (but can have multiple) in which case the fields for those
    ::  tags should be atoms (to store counts)
    +$  required-tags  $:
        dtstamp=galf
        uid=galf
        dtstart=galf
        ::  either dtend or duration
        dtend-duration=galf
        ==
    ::  tags we expect to see no more than once (zero or one times)
    +$  unique-tags  $:
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
    ::  possible properties to parse for a vevent
    ::  comments reflect the field in vevent they refer to if the name
    ::  doesn't match the tag itself
    +$  vevent-tag  $?
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
        %recurrence-id
        %attach
        %attendee
        %contact
        %rstatus
        %related
        %resources
        ==
    ::  This type is for the functions we call to update our vevent. Each
    ::  tag we're parsing will have a corresponding function of this type.
    ::  The first argument is the token containing the data for the tag,
    ::  the second is the list of properties specified for the tag.
    +$  parser-fn  $-  [tape (map tape tape) vevent required-tags unique-tags]
                   [vevent required-tags unique-tags]
    ::  TODO So is there some way to refactor these so the common parts
    ::  are collapsed? look into it...
    ::
    ::  used for tags we don't support
    ++  no-parse
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        :+(v rt ut)
    ++  parse-dtstamp
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  dtstamp.rt
          !!
        :+
        v(dtstamp (parse-datetime-value t))
        rt(dtstamp &)
        ut
    ++  parse-dtstart
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  dtstart.rt
          !!
        :+
        v(dtstart (parse-date-or-datetime t))
        rt(dtstart &)
        ut
    ++  parse-dtend
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  dtend-duration.rt
          !!
        :+
        v(end [%dtend (parse-date-or-datetime t)])
        rt(dtend-duration &)
        ut
    ++  parse-vevent-duration
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  dtend-duration.rt
          !!
        =/  dur=[sign=? t=tarp]  (parse-duration t)
        ::  assert positive duration for vevent
        ?>  sign.dur
        :+
        v(end [%duration t.dur])
        rt(dtend-duration &)
        ut
    ++  parse-uid
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  uid.rt
          !!
        :+
        v(uid (crip t))
        rt(uid &)
        ut
    ++  parse-organizer
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  organizer.ut
          !!
        :+
        v(organizer `t)
        rt
        ut(organizer &)
    ++  parse-categories
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        =/  cats=wall  (split t com)
        :+(v(categories (weld cats categories.v)) rt ut)
    ++  parse-class
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  class.ut
          !!
        =/  class  (^:(event-class) (crip (cass t)))
        :+
        v(classification `class)
        rt
        ut(class &)
    ++  parse-comment
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        :+(v(comment [t comment.v]) rt ut)
    ++  parse-description
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  description.ut
          !!
        :+
        v(description `t)
        rt
        ut(description &)
    ++  parse-summary
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  summary.ut
          !!
        :+
        v(summary `t)
        rt
        ut(summary &)
    ++  parse-geo
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?~  geo.ut
          !!
        ::  we expect two semicolon separated float values
        =/  tokens=(list tape)  (split t mic)
        ?>  =((lent tokens) 2)
        =/  ll=latlon
            :-
            (parse-float (snag 0 tokens))
            (parse-float (snag 1 tokens))
        :+
        v(geo `ll)
        rt
        ut(geo &)
    ++  parse-location
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  location.ut
          !!
        :+
        v(location `t)
        rt
        ut(location &)
    ++  parse-status
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  status.ut
          !!
        =/  status  (^:(event-status) (crip (cass t)))
        :+
        v(status `status)
        rt
        ut(status &)
    ++  parse-subcomponent
        |=  [lines=wall t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ::  events only support nested valarm components
        ?>  =(t "VALARM")
        =/  alarm=(unit valarm)  (parse-valarm lines)
        ?~  alarm
          :+(v rt ut)
        :+
        v(alarms [u.alarm alarms.v])
        rt
        ut
    ++  parse-rrule
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  rrule.ut
          !!
        :+
        v(rrule `(parse-recur t))
        rt
        ut(rrule &)
    ++  parse-rdate
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        =/  tokens=(list tape)  (split t com)
        =/  f=$-(tape rdate)
            =/  res=(unit tape)  (~(get by props) "VALUE")
            ::  value sig or not period, it's a date or datetime
            ?:  |(?=($~ res) !=(u.res "PERIOD"))
              |=(tok=tape [%time (parse-date-or-datetime tok)])
            |=(tok=tape [%period (parse-period tok)])
        :+
        v(rdate (weld rdate.v (turn tokens f)))
        rt
        ut
    ++  parse-exdate
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        =/  date-strings=(list tape)  (split t com)
        =/  dates=(list ical-time)
            (turn date-strings parse-date-or-datetime)
        :+
        v(exdate (weld exdate.v dates))
        rt
        ut
    ++  parse-created
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  created.ut
          !!
        =/  dt  (parse-datetime-value t)
        ?>  utc.dt
        :+
        v(created `dt)
        rt
        ut(created &)
    ++  parse-last-modified
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  last-modified.ut
          !!
        =/  dt  (parse-datetime-value t)
        ?>  utc.dt
        :+
        v(last-modified `dt)
        rt
        ut(last-modified &)
    ++  parse-sequence
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  sequence.ut
          !!
        :+
        v(sequence (from-digits (scan t digits)))
        rt
        ut(sequence &)
    ++  parse-transparency
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  transp.ut
          !!
        :+
        v(transparency (^:(vevent-transparency) (crip (cass t))))
        rt
        ut(transp &)
    ++  parse-priority
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  priority.ut
          !!
        =/  prio=@  (from-digits (scan t digits))
        ?>  (in-between [0 9] prio)
        :+
        v(priority prio)
        rt
        ut(priority &)
    ++  parse-url
        |=  [t=tape props=(map tape tape) v=vevent rt=required-tags ut=unique-tags]
        ^-  [vevent required-tags unique-tags]
        ?:  url.ut
          !!
        :+
        v(url `t)
        rt
        ut(url &)
    --
::  get lines of a file in order
++  read-file
    |=  pax=path
    ^-  wall
    ::  request lines from clay
    =/  lines=tang  (pretty-file .^(noun %cx pax))
    =/  tapes=wall
    %+  turn
    lines
    |=(t=tank ~(ram re t))
    ::  now drop last item from list as it's a sig
    (oust [(dec (lent tapes)) 1] tapes)
::  "unfold" lines, as per the rfc. CRLF and then a whitespace
::  signifies a fold, so we join together lines separated by this
::  with the separations removed
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
    ++  wsp  ;~(pose ace (jest '\09'))
    ::  See if two lines should be unfolded. Produces a unit tape
    ::  which contains the unfolded line if it was possible to unfold.
    ::  we assume that the first tape ended in a newline.
    ++  unfold
        |=  [first=tape second=tape]
        ^-  (unit tape)
        =/  n=@  (dec (lent first))
        =/  res  (rust second ;~(plug wsp (star next)))
        ::  check for failures
        ::  second line doesn't start with a whitespace
        ?~  res
          ~
        ::  first line doesn't end in carriage return
        ?:  !=((snag n first) '\0d')
          ~
        ::  trim carriage return
        =/  f-prefix=tape  (scag n first)
        ::  trim whitespace
        =/  s-tail=tape  +:u.res
        `(weld f-prefix s-tail)
    --
::  parse a calendar into a list of vevents. Since vevents aren't
::  nestable, we can search forward until we find the next one
++  parse-calendar
    =<
    |=  lines=wall
    =/  n=@  (lent lines)
    ?>  (gte n 2)
    ?>  =((snag 0 lines) "BEGIN:VCALENDAR")
    ?>  =((snag (dec n) lines) "END:VCALENDAR")
    ::  this is needed to get lines to be a lest. I tried
    ::  directly casting it in the below expression, but it
    ::  didn't work. i.e. t:`(lest tape)`lines
    ?~  lines
      !!
    ::  get rid of vcalendar begin/end
    =/  trimmed-lines=wall
        (oust [(sub n 2) 1] t.lines)
    ::  now go through lines and get the indices of begins/ends for events
    ::  this whole method is horrendously nonperformant, but will do for testing
    =/  begin-indices=(list @)  (fand ~["BEGIN:VEVENT"] trimmed-lines)
    =/  end-indices=(list @)  (fand ~["END:VEVENT"] trimmed-lines)
    ?>  =((lent begin-indices) (lent end-indices))
    ::  extract lines containing top level calendar properties
    ::  currently just grabbing first two lines, but this can be changed
    ::  depending on whether or not we support more top level calendar
    ::  properties.
    =/  cal-props=(list tape)  (scag 2 trimmed-lines)
    =/  cal=calendar  (parse-calendar-props cal-props)
    |-
    ?~  begin-indices
      ?~  end-indices
        cal
      !!
    ?~  end-indices
      !!
    ::  get indices in trimmed lines that don't include the begin/end tags.
    ::  extract those lines from target-lines and construct a vevent from them
    =/  begin=@  +(i.begin-indices)
    =/  num-lines=@  (sub i.end-indices begin)
    =/  target-lines=wall  (swag [begin num-lines] trimmed-lines)
    =/  event=vevent  (parse-vevent target-lines)
    =/  new-cal=calendar  cal(events [event events.cal])
    $(begin-indices t.begin-indices, end-indices t.end-indices, cal new-cal)
    |%
    +$  required-tags  $:(prodid=galf version=galf)
    +$  vcal-tag  $?
        %version
        %prodid
        ==
    ++  parse-prodid
        |=  [t=tape c=calendar rt=required-tags]
        ^-  [calendar required-tags]
        ?:  prodid.rt
          !!
        :-
        c(prodid t)
        rt(prodid &)
    ++  parse-version
        |=  [t=tape c=calendar rt=required-tags]
        ^-  [calendar required-tags]
        ?:  version.rt
          !!
        :-
        c(version t)
        rt(version &)
    ::  builds calendar with top level properties populated
    ++  parse-calendar-props
        |=  [cal-props=(list tape)]
        ^-  calendar
        =|  cal=calendar
        =|  rt=required-tags
        |-
        ?~  cal-props
          ?:  &(prodid.rt version.rt)
            cal
          !!
        =/  tokens=(list tape)  (split-first i.cal-props col)
        ?>  =((lent tokens) 2)
        =/  tag  (^:(vcal-tag) (crip (cass (snag 0 tokens))))
        =/  parser=$-([tape calendar required-tags] [calendar required-tags])
        ?-  tag
          %version  parse-version
          %prodid  parse-prodid
        ==
        =/  res=[c=calendar rt=required-tags]
            (parser (snag 1 tokens) cal rt)
        $(cal-props t.cal-props, rt rt.res, cal c.res)
    --
++  calendar-from-file
    |=  pax=path
    ^-  calendar
    =/  lines=wall
        %+  turn
        (unfold-lines (read-file pax))
        ::  now trim trailing carriage-returns
        |=  t=tape
        =/  n=@  (dec (lent t))
        ?:  =((snag n t) '\0d')
          (scag n t)
        t
    (parse-calendar lines)
--
