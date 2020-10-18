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
`cal-code` and `event-code` are unique per calendar/event and are just `@ud`s. For the scry for events in range, start and end are `@da`s.
| Path                                     | Return type                                  | Notes                                                                                                                                                                                                                                                                                                                   |
|------------------------------------------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `%y %calendars`                            | (list calendar)                              | all calendars                                                                                                                                                                                                                                                                                                           |
| `%y %events`                               | (list event)                                 | all events                                                                                                                                                                                                                                                                                                              |
| `%y %calendars cal-code`                   | (unit calendar)                              | a specific calendar                                                                                                                                                                                                                                                                                                     |
| `%y %events %specific cal-code event-code` | (unit event)                                 | a specific event on a specific calendar                                                                                                                                                                                                                                                                                 |
| `%y %events %bycal cal-code`               | (list event)                                 | all events on a specific calendar                                                                                                                                                                                                                                                                                       |
| `%y %events %inrange cal-code start end`   | (unit [(list event) (list projected-event)]) | produces two lists if a calendar with the specified code exits, unit otherwise. the  (list event) is exactly what you'd expect and the (list projected-event) contains specific instances of recurring events found in the target range. the convention is start then end, but they can be supplied in reverse as well. |

### Creating a calendar/event with a generator
Run `:ucal-store|create-calendar some-title-cord` to create a calendar. The same syntax can be used for creating events, with `create-event` instead (there's a different set of arguments). The generators can be found in `urbit/gen/ucal-store` and an explanation of this syntax is [here.](https://github.com/timlucmiptev/gall-guide/blob/master/generators.md)


### Subscribing to calendars on other ships
Not yet implemented.

### Inviting ships to your events
Not ye implemented.

## Current Roadmap
These are the current big tasks to undertake (and their relative priorities)

1. hook development
2. pH testing
3. almanac update to use ordered map, dovetails with gall agent enrichment to support date-range queries for events

### pH Testing
branch: aqua-testing

We want tests to verify calendar/event creation, destruction, and updating. There should also be tests for rsvping, event permissions, etc. once the hook is in more robust shape.

### almanac update
branch: none yet

The data structure used to currently store events (the almanac) is naively implemented and can be improved. I think there's an ordered map somewhere in the la/graph-store branch of the main urbit repo (++mop) that we may be able to use here. It might also be worth implementing an [Interval Tree](https://en.wikipedia.org/wiki/Interval_tree) as this seems to be the most efficient data structure for these types of queries.

### hook development
branch: pull-push-hooks

use lib-hook to implement the push/pull hook pattern
