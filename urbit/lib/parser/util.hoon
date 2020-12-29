/+  pretty-file
::  Core containing some useful parsing idioms
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
::  +startswith: checks if a given tape has a prefix matching a given
::  rule
::
++  startswith
    |*  [t=tape rul=rule]
    ^-  flag
    (matches t ;~(plug rul (star next)))
::  +whut:  rule builder for matching 0 or 1 time. regex '?'
::
++  whut  |*(rul=rule (stun [0 1] rul))
::
++  digits  (plus dit)
::
++  two-dit  ;~(plug dit dit)
::
++  four-dit  ;~(plug dit dit dit dit)
::  +whitespace: terran whitespace (includes newlines and tabs)
::
++  whitespace  (cold ~ (plus ;~(pose vul gah (jest '\\n') (jest '\09'))))
::  +optional-sign:  rule for parsing optional signs.
::
++  optional-sign
  %+  cook
    |=(x=tape !=(x "-"))  ::  %.y if we don't have '-', %.n otherwise
  (whut ;~(pose lus hep))  ::  the sign itself is optional
::  +split-non-escaped: splits tape on rul unless matching segment is preceded by a '\'
::
++  split-non-escaped
    |*  [t=tape rul=rule]
    ^-  (list tape)
    %+  scan
      t
    %+  more  rul
      %+  cook  zing
      (star ;~(pose ;~(plug bas next (easy ~)) ;~(less rul ;~(plug next (easy ~)))))
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
::  +strip-trailing-whitespace: delete trailing whitespace from a line
::
++  strip-trailing-whitespace
  |=  line=tape
  ^-  tape
  =/  res=(unit tape)  (rust (flop line) ;~(pfix whitespace (star next)))
  ?~  res
    line
  (flop u.res)
::  +remove-inline-comments: remove '#' prefixed comments
::
++  remove-inline-comments
  |=  line=tape
  ^-  tape
  =/  comment-ind=(unit @)  (find "#" line)
  ?~  comment-ind
    line
  (scag u.comment-ind line)
::  +read-file:  get lines of a file in order
::
++  read-file
  |=  pax=path
  ^-  wall
  ::  request lines from clay
  ::
  =/  lines=tang  (pretty-file .^(noun %cx pax))
  %+  turn
    lines
  |=(t=tank ~(ram re t))
--
