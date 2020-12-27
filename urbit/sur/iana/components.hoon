/-  hora
|%
::  $delta: signed time - sign is & for positive and | for negative
::
+$  delta  [sign=flag d=@dr]
::  $tz-rule: parsed 'Rule' component
::
+$  tz-rule
  $:  name=@ta
      ::  rules for local standard time
      standard=(list rule-entry)
      ::  rules for daylight saving time
      saving=(list rule-entry)
  ==
::  $rule-entry: represents a delta applying to a range of time
::
::  from/to: the entry applies for the years in the range [from, to].
::           if 'to' is unit the entry is valid anytime after 'from'
::  in: month the entry takes effect (1-12)
::  on: either a specific day of the month (i.e. 12th), a specific
::      weekday (i.e. last sunday), or the first instance of a weekday
::      after a given day (i.e. first Monday >= 16th)
::  at: offset on the specific day that the entry becomes valid.
::  save: delta we apply to local standard time under this entry.
::  letter: variable part of zone's name determined by entry. despite
::          the name it can be more than one letter in rare cases.
::
+$  rule-entry
  $:  from=@ud
      to=(unit @ud)
      in=@ud
      on=rule-on
      at=[offset=@dr type=rule-at-type]
      save=delta
      letter=@t
  ==
::
+$  rule-on
  $@
    @ud
    [weekday:hora $%([%instance weekday-instance:hora] [%on @ud])]
::
+$  rule-at-type  ?(%standard %utc %wallclock)
::  $zone: parsed 'Zone' component

::
+$  zone
  $:  name=@ta
      entries=(list zone-entry)
  ==
::  $zone-entry: timezone data for a given time range
::
::  stdoff: utc offset
::  rules: additional offsets for this timezone (i.e daylight saving time).
::         can be %nothing (no additional offset), %delta (a specific offset)
::         or %rule (offset depends on a rule component)
::  abbreviation: abbreviation for timezone.
::  from/to: entry is valid in the range [from, to]. if 'to' is unit, valid from
::           indefinitely starting at 'from'.
+$  zone-entry
  $:  stdoff=delta
      rules=$%([%nothing ~] [%delta =delta] [%rule name=@ta])
      ::  TODO might be worth handling each case here separately and
      ::  exposing some get-abbreviation function for a zone (takes
      ::  a local time).
      abbreviation=@t
      from=@da
      to=(unit @da)
  ==
--
