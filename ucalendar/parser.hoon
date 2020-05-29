/+  pretty-file, ucalendar-components, ucalendar-calendar
=,  [ucalendar-components ucalendar-calendar]
::  Core for parsing ical files. The goal of this file is to go from ical file
::  to a list of unfolded strings (cords?) with all characters escaped
|%
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
::  parses a signed floating point from a string
++  parse-float
    |=  t=tape
    ^-  dn
    =/  rul
        ;~
          plug
          %+  cook
            |=(x=tape !=(x "-")) ::  %.y if we don't have '-', %.n otherwise
            (stun [0 1] ;~(pose lus hep)) :: optional sign
          (plus dit)
          (stun [0 1] ;~(plug dot (plus dit)))
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
::  parses a recurrence rule
++  parse-recur-rule
    |=  t=tape
    ::  TODO implement
    !!
::  used for rdate and exdate, both are a comma separated list of dates or datetimes
::  TODO nvm rdate also has period in it, RIP. Should we support it?
++  parse-dates
    |=  t=tape
    ^-  (list date)
    %+  turn
    (split t com)
    parse-date-or-datetime
::  parses a period
++  parse-period
    |=  t=tape
    ::  TODO implement
    !!
::  takes a tape representing a duration, produces a cell of tarp and a
::  flag representing whether the duration is positive or negative,
::  %.y for positive and %.n for negative
++  parse-duration
    =<
    |=  t=tape
    ^-  [? tarp]
    =/  dur-sec  (cook cook-sec ;~(plug (plus dit) (jest 'S')))
    =/  dur-min  (cook cook-min ;~(plug (plus dit) (jest 'M') (stun [0 1] dur-sec)))
    =/  dur-hour  (cook cook-hour ;~(plug (plus dit) (jest 'H') (stun [0 1] dur-min)))
    =/  dur-day  (cook cook-day ;~(plug (plus dit) (jest 'D')))
    =/  dur-week  (cook cook-week ;~(plug (plus dit) (jest 'W')))
    =/  dur-time  (cook cook-time ;~(plug (jest 'T') ;~(pose dur-hour dur-min dur-sec)))
    =/  dur-date  (cook cook-date ;~(plug dur-day (stun [0 1] dur-time)))
    =/  res=[f=? =cord tar=tarp]
    %+  scan  t
    ;~
      plug
      %+  cook
      |=  x=tape
          !=(x "-")  ::  produce %.y if we don't have '-', %.n otherwise
      (stun [0 1] ;~(pose lus hep)) :: optional sign
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
    ^-  date
    ::  check if length of tape is 8. If it is, dtstamp is a date.
    ::  otherwise, it's a date-time
    ?:  =((lent t) 8)
      (parse-date-value t)
    (parse-datetime-value t)
::  parse an ics date value - a tape of the form "YYYYMMDD"
++  parse-date-value
    |=  t=tape
    ^-  date
    =|  d=date
    =/  four-dit-rul  ;~(plug dit dit dit dit)
    =/  two-dit-rul  ;~(plug dit dit)
    ::  parse tape into [[Y Y Y Y] [M M] [D D]]
    =/  res  (scan t ;~(plug four-dit-rul two-dit-rul two-dit-rul))
    =/  day=@  (from-two-digit +>:res)
    =/  month=@  (from-two-digit +<:res)
    =/  yc=[a=@ b=@ c=@ d=@]  -:res
    ::  computes 1000*a + 100*b + 10*c + d
    =/  year=@
        %+  add
        (mul 100 (from-two-digit [a.yc b.yc]))
        (from-two-digit [c.yc d.yc])
    d(y year, m month, d.t day)
::  parses an ics datetime, formatted as: YYYYMMDD followed by a 'T' and
::  then the time. time is formatted as HHMMSS for hour, minute, and second.
::  optionally, there may also be a 'Z' at the end, signifying UTC time
++  parse-datetime-value
    |=  t=tape
    ^-  date
    ::  expect two tokens here
    =/  tokens=(list tape)  (split t (jest 'T'))
    =/  d=date  (parse-date-value (snag 0 tokens))
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
          (stun [0 1] (jest 'Z'))
        ==
    =/  hours=@  (from-two-digit -:res)
    =/  minutes=@  (from-two-digit +<:res)
    =/  seconds=@  (from-two-digit +>-:res)
    ::  TODO handle UTC logic
    =/  utc=?  =(+>+:res "Z")
    d(h.t hours, m.t minutes, s.t seconds)
++  parse-vevent
    =<
    |=  w=wall ::  (list tape)
    ^-  vevent
    =|  v=vevent
    =/  ut=unique-tags  [| | | |]
    |-
    ::  if we're out of lines, produce v.
    ?~  w
      ::  now check if all fields in ut are true - if not, we are missing
      ::  a required field
      ?:  &(dtstamp.ut uid.ut dtstart.ut dtend-duration.ut)
        v
      !!
    =/  tokens=(list tape)  (split i.w col)
    ::  assert we have two tokens
    ?>  =((lent tokens) 2)
    ::  now break first token up along its params (split on semicolon)
    =/  props=(list tape)  (split (snag 0 tokens) mic)
    ::  lowercase and convert to term to switch against union
    =/  tag  (^:(vevent-tag) (crip (cass (snag 0 props))))
    ::  each tag will have a corresponding function that takes the second token
    ::  and the current vevent and produces a new vevent. all of these
    ::  functions will have the form
    ::  [tape vevent unique-tags] -> [vevent unique-tags]
    =/  parser=$-([tape vevent unique-tags] [vevent unique-tags])
    ?-  tag
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
    ==
    =/  res=[v=vevent ut=unique-tags]
        (parser (snag 1 tokens) v ut)
    $(w t.w, v v.res, ut ut.res)
    |%
    ::  tags we expect to see exactly once (required)
    ::  these can be flags, unless there are tags we require at least
    ::  once (but can have multiple) in which case the fields for those
    ::  tags should be atoms (to store counts)
    +$  unique-tags  $:
        dtstamp=?
        uid=?
        dtstart=?
        ::  either dtend or duration
        dtend-duration=?
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
        ==
    ::  TODO So is there some way to refactor these so the common parts
    ::  are collapsed? look into it...
    ++  parse-dtstamp
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        ?:  dtstamp.u
          !!
        :-
        v(dtstamp (parse-date-or-datetime t))
        u(dtstamp &)
    ++  parse-dtstart
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        ?:  dtstart.u
          !!
        :-
        v(dtstart (parse-date-or-datetime t))
        u(dtstart &)
    ++  parse-dtend
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        ?:  dtend-duration.u
          !!
        :-
        v(end [%dtend (parse-date-or-datetime t)])
        u(dtend-duration &)
    ++  parse-vevent-duration
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        ?:  dtend-duration.u
          !!
        =/  dur=[sign=? t=tarp]  (parse-duration t)
        ::  assert positive duration for vevent
        ?>  sign.dur
        :-
        v(end [%duration t.dur])
        u(dtend-duration &)
    ++  parse-uid
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        ?:  uid.u
          !!
        :-
        v(uid (crip t))
        u(uid &)
    ++  parse-organizer
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        :-(v(organizer [~ t]) u)
    ++  parse-categories
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        =/  cats=wall  (split t com)
        :-(v(categories (weld cats categories.v)) u)
    ++  parse-class
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        =/  class  (^:(event-class) (crip (cass t)))
        :-(v(classification [~ class]) u)
    ++  parse-comment
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        :-(v(comment [t comment.v]) u)
    ++  parse-description
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        :-(v(description [~ t]) u)
    ++  parse-summary
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        :-(v(summary [~ t]) u)
    ++  parse-geo
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        ::  we expect two semicolon separated float values
        =/  tokens=(list tape)  (split t mic)
        ?>  =((lent tokens) 2)
        =/  ll=latlon
            :-
            (parse-float (snag 0 tokens))
            (parse-float (snag 1 tokens))
        :-(v(geo [~ ll]) u)
    ++  parse-location
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        :-(v(location [~ t]) u)
    ++  parse-status
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        =/  status  (^:(event-status) (crip t))
        :-(v(status [~ status]) u)
    ++  parse-subcomponent
        |=  [t=tape v=vevent u=unique-tags]
        ^-  [vevent unique-tags]
        ::  TODO implement
        !!
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
::  actually parse a calendar into a list of vevents. Since vevents aren't
::  nestable, we can search forward until we find the next one
++  parse-calendar
    =<
    |=  lines=wall
    =|  cal=calendar
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
    |-
    ?~  begin-indices
      ?~  end-indices
        cal
      !!
    ?~  end-indices
      !!
    ::  get indices in trimmed lines that don't include the begin/end tags
    =/  begin=@  +(i.begin-indices)
    =/  num-lines=@  (sub i.end-indices begin)
    =/  target-lines=wall  (swag [begin num-lines] trimmed-lines)
    =/  event=vevent  (parse-vevent target-lines)
    =/  new-cal=calendar  cal(events [event events.cal])
    $(begin-indices t.begin-indices, end-indices t.end-indices, cal new-cal)
    |%
    +$  unique-tags  $:(prodid=? version=?)
    ++  parse-prodid
        |=  [t=tape c=calendar u=unique-tags]
        ^-  [calendar unique-tags]
        ?:  prodid.u
          !!
        :-
        c(prodid t)
        u(prodid &)
    ++  parse-version
        |=  [t=tape c=calendar u=unique-tags]
        ^-  [calendar unique-tags]
        ?:  version.u
          !!
        :-
        c(version t)
        u(version &)
    --
--
