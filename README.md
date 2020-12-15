# Urbit Calendar

## Usage
Clone the repository and then create a .urbitrc in the root. It should look like
```
module.exports = {
  URBIT_PIERS: [
    "/path/to/first/pier/zod/home",
    "/path/to/other/pier/nel/home"
  ]
};

```
Then run `yarn build` from the project root to copy the files into the target pier(s). Finally, `mount |%home` and `|start %ucal-store` to get the app running.

### Pokes
The best documentation for these is the source code for `action` in `sur/ucal-store.hoon`. They're all pretty straightforward to use, though there are some convenience generators for calendar/event creation we'll talk about later.

### Scrys
`cal-code` and `event-code` are unique per calendar/event and are just `@tas`s (they're just uuids). For the scry for events in range, start and end are `@da`s. `ship` is an `@p` whose almanac (a collection of calendars and events) we're examining.
| Path                                     | Return type                                  | Notes                                                                                                                                                                                                                                                                                                                   |
|------------------------------------------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `%y ship %calendars`                            | (list calendar)                              | all calendars                                                                                                                                                                                                                                                                                                           |
| `%y ship %events`                               | (list event)                                 | all events                                                                                                                                                                                                                                                                                                              |
| `%y ship %calendars cal-code`                   | (unit calendar)                              | a specific calendar                                                                                                                                                                                                                                                                                                     |
| `%y ship %events %specific cal-code event-code` | (unit event)                                 | a specific event on a specific calendar                                                                                                                                                                                                                                                                                 |
| `%y ship %events %bycal cal-code`               | (list event)                                 | all events on a specific calendar                                                                                                                                                                                                                                                                                       |
| `%y ship %events %inrange cal-code start end`   | (unit [(list event) (list projected-event)]) | produces two lists if a calendar with the specified code exits, unit otherwise. the  (list event) is exactly what you'd expect and the (list projected-event) contains specific instances of recurring events found in the target range. the convention is start then end, but they can be supplied in reverse as well. |

### Creating a calendar/event with a generator
Run `:ucal-store|create-calendar some-title-cord` to create a calendar. The same syntax can be used for creating events, with `create-event` instead (there's a different set of arguments). The generators can be found in `urbit/gen/ucal-store` and an explanation of this syntax is [here.](https://github.com/timlucmiptev/gall-guide/blob/master/generators.md)

### Other useful generators
`+all-calendars, =who (unit @p), =local flag` : Dumps a list of metadata (`[owner title code]` tuples) so you can quickly see what calendars are in the store for a given ship (defaults to current ship if not specified). If local is specified to be false, queries the pull-hook instead (we'll elaborate on this later). Useful in conjunction with...

`+events-in-range =calendar-code start=@da end=@da, who=(unit @p)` : Gets the events in the specified date range for the specified calendar on the specified ship (who). if no ship is specified we again default to the current ship.

Both of these are simple wrappers around some of the scries listed above, but they're nice for quickly checking the state of your calendar(s).

### Subscribing to calendars on other ships
To enable this, you'll need to start `ucal-push-hook` on the ship you're subscribing to and `ucal-pull-hook` on the ship you're subscribing from (you might as well start them both on every ship though).  Here's an overview of how to set this up with ~zod subscribing to a calendar on ~nel.

1. On ~nel run `+all-calendars` to examine the available calendars. Let's say we have one with code `%abcd-efgh` that we want ~zod to subscribe to.
2. ~zod needs a way of finding out what calendars ~nel is making available for subscription. While ~nel _could_ just DM ~zod the calendar code, ~zod can also use `:ucal-pull-hook|query-cals ~nel` - this is a poke sent to the pull-hook that pulls in calendar metadata from ~nel.
3. Now ~zod can run `+all-calendars, =who [~ ~nel], =local |` (note the `=local` argument we mentioned earlier) to get this information from its local pull-hook. ~zod should see an entry with code `%abcd-efgh`.
4. ~zod should now run `:ucal-pull-hook &pull-hook-action [%add ~nel [~nel %abcd-efgh]]`

Now if ~nel creates events on this calendar, they'll be sent to ~zod's store (this can be verified by scrying, `events-in-range`, or just doing `:ucal-store %print-state`). Event updates and deletions will also be sent over to ~zod. If the calendar is deleted, ~zod will be unsubscribed and the calendar in ~zod's store will be deleted. If ~zod wants to manually unsubscribe we can poke the pull hook as follows.
`:ucal-pull-hook &pull-hook-action [%remove ~nel %abcd-efgh]`

### Inviting ships to your events
Not yet implemented.

### Permissions
Permissions are implemented at the calendar level. Ships fall into three
roles: readers, writers, and acolytes. These correspond to allowing ships
to {subscribe to, edit, change permissions of} a calendar respectively.
Being an acolyte implies being a writer, and being a writer implies being
a reader. If a ship loses read access it will be kicked from its current
subscription (if it has one) and will be prevented from resubscribing until
it's readded. Calendars can also be specified to be public, giving every
ship read access to it. It's also worth noting that if a ship doesn't have
read access to a calendar they won't be aware of its existence (unless they
were previously kicked from it) - `query-cals` will not report any
calendars the querying ship isn't allowed to read.

## Current Roadmap
These are the current big tasks to undertake (in no particular order).

1. almanac update to use ordered map (and potentially implementing an interval tree)
2. timezones
3. invites
4. more ph tests (sadly broken atm)


### almanac update
branch: none

The data structure used to currently store events (the almanac) is naively implemented and can be improved. I think there's an ordered map somewhere in the la/graph-store branch of the main urbit repo (++mop) that we may be able to use here. It might also be worth implementing an [Interval Tree](https://en.wikipedia.org/wiki/Interval_tree) as this seems to be the most efficient data structure for these types of queries.

### timezones
branch: none

As of this moment there's just some stub code and ideas for how to handle timezones. The current model of "just make everything UTC" is not particularly compelling - improvements can certainly be made. There are a few approaches, the most involved being to parse the IANA timezone database (a potentially herculean effort). There may be a middle ground where certain timezones can be hardcoded in some way, but ultimately parsing the db is probably the best way to go.

### invites
branch: none

The data types for invites are floating around and through the code, but they aren't used in any way. This will involve work at the hook level and some store changes.

### pH Testing (broken as of network breach)
branch: none

We have tests to verify calendar/event creation, destruction, and updates. There's also a test that demonstrates the hooks in use - subscriptions to calendars, updates propagating, and eventually stopping when the calendar is deleted. As more functionality (i.e. invites) is added, more tests will be needed (you can't have too many tests right?).


##  Doesn't this need a frontend?
Yes, it does! I'm not sure I have the time/expertise/motivation to make one so if you're interested _please_ submit a PR. I'm happy to answer any questions about the stores/hooks and can make any changes that're necessary.
