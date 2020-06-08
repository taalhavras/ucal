::  Mark for ics files
|_  own=@t ::  TODO @t or wain?
++  grow  ::  convert to
    |%
    ++  mime  `^mime`[/text/calendar (as-octs:mimes:html own)]
    ++  txt  ^-  wain  ~[own]
    --
++  grab  ::  convert from
    |%
    ++  mime
        |=  [p=mite:eyre q=octs:eyre]
        ^-  @t
        q.q
    ++  txt  of-wain:format ::  wain to cord
    --
++  grad  %txt  ::  diff/merge same as txt files
--
