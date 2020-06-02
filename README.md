# Urbit Calendar

## Parser TODOs

1. (DONE) Parsing for recurrence rules (rrule, rdate, exdate).
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
4. (DONE) In this vein, we should probably take distinguish DATE and DATE-TIME.
   I (raghu) am gonna just do this on a separate branch and then merge
   it since it's a pretty large change. there will be a unified type
   (ical-time or some such) with both date and date-time in it. This will
   change pretty much every place urbit's date type is used in the code.
5. For some properties that can be dates or date-times, there is probably
   a way to enforce that they're all either one or the other. This would
   more closely mirror what the ical spec actually says and would be a nice
   way of having the type system reflect that validation.
   Stuff like exdate is easy (define a new type that's either a list of
   ical-date or ical-datetime), but things like dtstart/dtend might be more
   tricky? Would probably need a separate type for both of them, either
   two ical-dates or ical-datetimes. This might not be an immediate concern,
   but is definitely something we want IMO.

## General TODOs

1. ucal spec - how does it differ from ical, what operations will we support, etc.
2. It'd be nice to have a mark for ics files so they don't have to be stored as
   ".txt" files in urbit.
