# Urbit Calendar

## Usage


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
