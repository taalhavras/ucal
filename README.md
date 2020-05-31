# Urbit Calendar

## Parser TODOs

1. Parsing for recurrence rules (rrule, rdate, exdate).
   These are the most important properties that haven't yet
   been parsed.
2. Parsing for optional ical component properties. See
   [the rfc](https://tools.ietf.org/html/rfc5545#section-3.3.4)
   for more info. Since we want the ical part of this to handle
   all possibilities for the rfc when it comes to VEVENTS (ucal
   will cut this down to what we're really interested in), we should
   support all possible properties here. This will be somewhat tedious,
   but shouldn't be too tricky
3. Using properties where appropriate. For example, dtstart has
   an optional tzid property that we currently don't look for or store.
   there are a fair number of these, so it'll be a lot of RFC reading.



## General TODOs

1. ucal spec - how does it differ from ical, what operations will we support, etc.
2. It'd be nice to have a mark for ics files so they don't have to be stored as
   ".txt" files in urbit.
