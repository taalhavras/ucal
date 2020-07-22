# Urbit Calendar

## Current Roadmap
These are the current big tasks to undertake

1. pH testing
2. almanac update to use ordered map, dovetails with gall agent enrichment to support date-range queries for events
3. hook development
4. data model + recurring events

With regards to how they should be prioritized, I think finalizing the data model is probably the most important thing and should be prioritized first. Once that's done, the hook and almanac updates can proceed independently.

### pH Testing
branch: aqua-testing

We want tests to verify calendar/event creation, destruction, and updating. There should also be tests for rsvping, event permissions, etc. once the hook is in more robust shape.

### almanac update
branch: none yet

The data structure used to currently store events (the almanac) is naively implemented and can be improved. I think there's an ordered map somewhere in the la/graph-store branch of the main urbit repo (++mop) that we may be able to use here.

### hook development
branch: none yet

The current "hook" doesn't really fulfill the standards of a "hook" according to the [userspace development guidelines](https://docs.google.com/document/d/1hS_UuResG1S4j49_H-aSshoTOROKBnGoJAaRgOipf54/edit?ts=5d533e42). A fully fleshed out hook would communicate with hooks on other ships and would also have some sort of permissions system informing who can see what events and who can edit them.

### data model + recurring events
branch: josh/data-model

This branch contains some improvements/tweaks to the data model (event/calendar representation) but it's not fully fleshed out yet. Continuing this work would mean fleshing out what recurrence rules are as well (and how closely they'd mirror our current representation of ics recurrence rules). The bigger issue though is how to model recurring events in our calendars. This ties into the almanac update so work on these two tasks could be done together and it might be worth exploring prior literature (i.e. other languages' implementations of calendaring) to see how they've solved this problem.
