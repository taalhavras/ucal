::  Mark for ics files
|_  own=@t
++  grow  ::  convert to
    |%
    ++  mime  `^mime`[/text/calendar (as-octs:mimes:html own)]
    ++  txt  ^-  wain  ~[own]
    --
++  grab  ::  convert from
    |%
    ++  mime
        |=  [p=mite q=octs]
        ^-  @t
        q.q
    ++  txt  of-wain:format ::  wain to cord
    --
++  grad  %txt  ::  diff/merge same as txt files
--
