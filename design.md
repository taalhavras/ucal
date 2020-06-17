# Architecture #

Urbit currently ships (no pun intended) with a number of gall agents that have
been developed over several years, and there appear to be some emergent patterns
in agents that have also developed. What appears to be the current preferred
method of building userspace applications is outlined in [this
document](https://docs.google.com/document/d/1hS_UuResG1S4j49_H-aSshoTOROKBnGoJAaRgOipf54/edit?ts=5d533e42)
on Tlon's Userspace Architecture (TUA).

Following the conventions outlined in TUA, `ucalendar` should be broken into the
following agents:

- `app/ucal-store.hoon`: stores calendar-related data.
- `app/ucal-*-hook.hoon`: manages interactions with other agents, e.g. groups.
- `app/ucal-*-view.hoon`: (*out of scope*) provides client interface for eventual
  Landscape apps.
  - **NOTE:** `ucal-tile-view.hoon` and `ucal-land-view.hoon` might be
    appropriate.

A calendar is probably most useful as something that can be easily shared with
other ships. This makes it a natural fit for integration into the pre-existing
**Groups** mechanism, so the pattern of separating the responsibilities of our
application along the lines in the TUA makes sense. This not only seems the most
architecturally sound, but will also enable us to leverage prior art when adding
those functionalities.

### Resources ###

I'm using the **Links** application as an example project, as it appears to be
one of the more recently developed applications (I'm guessing designed with TUA
in place, unlike Chat and Publish) and is well-commented. Here are some places
to look to for inspiration:

- [link-store](https://github.com/urbit/urbit/blob/master/pkg/arvo/app/link-store.hoon):
  store agent for the **Links** application.
- [link-listen-hook](https://github.com/urbit/urbit/blob/master/pkg/arvo/app/link-listen-hook.hoon):
  link hooks for subscribing to other ships' links within the context of groups.
- [link-proxy-hook](https://github.com/urbit/urbit/blob/master/pkg/arvo/app/link-proxy-hook.hoon):
  serves as a proxy for local data in the store to other subscribed ships.
- [sur/link.hoon](https://github.com/urbit/urbit/blob/master/pkg/arvo/sur/link.hoon):
  data model for links

## icalendar Integration ##

`ucal` ships with [icalendar]() support, and should expose generators for
importing an `.ics` file into a target calendar.

- `gen/import-ics.hoon`: given a path to an ics file and calendar code, import
  all events into the specified calendar.
  - **NOTE:** allowing an input range to speciy would be a great idea here. If
    my calendar has years of historical data that I don't want (or is just
    gigantic), we could then only import events from a year ago and then all
    in the future.
- `gen/import-ics/...`: all supporting files for `import-ics` should go within
  this folder.

## `app/ucal-store.hoon` ##

> Stores are the foundational components of userspace, and can be referred to as
> "userspace infrastructure". They act as dumb data stores: small, conceptually
> simple, and complete.

Our store will manage the domain of calendar data: calendars, events, and RSVPs.

`calendars` contain many events. They define an owning ship, manage subscribers
(and the corresponding permissions), and may be part of groups. The `calendar`
represents a *channel*, like Chats, Notebooks and Links.

When viewing events in a `calendar`, we'll want to view them in a certain
timezone. It's likely that this can be handled by the client. When saving
events, timezone corrections may need to be made to ensure we're in UTC.

`events` can have many invitees who can each provide zero or one RSVP. I'm not
sure if this requires two data structures. We may be able to get away with a
single `invite` structure that has an `rsvp` enum, which defaults to `~`.

Additionally, `events` have a start and end date, description, title, organizer,
and optionally a set of recurrence rules. Recurrence rules should probably
mirror the `icalendar` spec fairly closely, as it's a general-purpose solution
to a non-trivial problem that we don't need to focus on reinventing. (TODO:)
Details on how we'll handle recurrence rules will be provided below.

### Interfaces ###

> Stores provide poke, peer and scry interfaces.

- **poke**: handles mutations, often resulting in publishing updates (giving
  `%fact`s) to subscribers.
- **peer**: can't find any documentation on the word "peer" in other gall
  reference materials, but I belive this is referring to managing of
  subscriptions.
- **scry**: a read-only namespace for exposing data.

Let's cover what should be provided for each of the above interfaces.

#### poke ####

These actions provide a CRUD-like interface for interacting with calendar data.

- `calendar-action`
  - `%import`: import all events in an ICS file into a given calendar.
  - `%create`: create a new calendar on `our`.
  - `%delete`: delete an existing calendar on `our`. Should delete all
    events, terminate all subscriptions.
  - `%add`: subscribe to a calendar on another ship.
  - `%remove`: unsubscribe from a calendar on another ship.
  - `%modify`: update properties of a calendar. As of now, that's pretty much
    just the title, so this seems not terribly urgent. Should only work for
    calendars owned by `our`.
  - how do invitations work? are those man
- `event-action`
  - `%create`: create a new event within a given calendar. A start and end date
    are required. We could do durations like icalendar does, or accept them and
    store them as absolute dates. Should publish to subscribers.
  - `%respond`: respond with an RSVP to an event. Should publish to subscribers.
  - `%delete`: delete event and publish deletion to subscribers.
  - `%modify`: update title, description, location, and any other properties of
    the event itself. Publishes updates to subscribers.
  - `%invite`: invite another ship to this event. Publishes updates to
    subscribers.
    - **NOTE:** If another ship gets an invite straight to an event, how do we
      determine which calendar to put the event on? Perhaps this is something
      managed by a `ucal-view` that provides a sort of "default calendar" that
      is used as a private calendar for the ship. This functionality would best
      be wrapped around calendar primitives like these, rather than built in at
      this level.
  - `%retract`: retract an invite to a given ship. Publishes updates to
    subscribers.

#### peer ####

This is the interface that I'm least comfortable with speccing out, as my
experience with subscription-based applications is limited. Bear that in mind,
and please consider the following with scrutiny.

Perusal of chat and link stores indicates that the `scry` and `peer` interfaces
are very similar. This makes sense, because the two are both concerned with
reading data. `scry` (`on-peek`) is for providing specific data on request,
whereas `peer` (`on-watch`) is for providing a series of updates (`[%give %fact ...]`)
for a specific path (set of resources) as they're delivered.

##### Marks #####

Subscriptions provide `*-update`, where `*` is the name of the app. Ours would
be `calendar-update`. You can see examples of this in the
`[link-store](https://github.com/urbit/urbit/blob/master/pkg/arvo/app/link-store.hoon#L371)`
and
`[chat-store](https://github.com/urbit/urbit/blob/master/pkg/arvo/app/chat-store.hoon#L72)`.
These updates are *marks*, which I believe are derived by the combination of
`mar/<app>/<mark>.hoon`, so a `mar/chat/update.hoon` is how we end up with
`%chat-update`. The pattern appears to be:

- Define an `+$  update` structure in `/sur`.
  - [link](https://github.com/urbit/urbit/blob/master/pkg/arvo/sur/link.hoon#L86)
  - [chat](https://github.com/urbit/urbit/blob/master/pkg/arvo/sur/chat-store.hoon#L48)
- Define a mark in `mar/<app>/<mark>.hoon`. In the example cases below, the
  `noun` arm of the `grow` and `grab` arms in the mark resolves to the the
  `update` structure defined in `/sur`.
  - [link](https://github.com/urbit/urbit/blob/master/pkg/arvo/mar/link/update.hoon)
  - [chat](https://github.com/urbit/urbit/blob/master/pkg/arvo/mar/chat/update.hoon)

These updates are examples of data that will be sent to other gall agents, hence
the need for marks.

TODO: More understanding of marks is needed.

#### scry ####

TODO:

--

## Misc Notes

* `%add-calendar`: Add another ship's calendar

## Data Structures

### Concrete v. Recurring

Two kinds of events:

1. concrete
2. recurring

Concrete events have a definite period, so they're not as interesting.

Recurring events have some sort of recurrence rule that can be used to reify
events within a given period. Reification of recurring events could be thought
of as an operation that creates concrete representations of an event upon an
attempt to view that period, but that could result in tremendous data growth.
Instead, perhaps reification only causes recurring events that have past
recurrences to persist to state, leaving events happening in the future as
"potential" events that look like persistent events...but are only derived? I'm
leaning towards the latter.

### RSVPs

```
(map event-id (map ship-name rsvp-info))
```

Special consideration will need to be given to storing RSVPs of "potential"
events (see Concrete v. Recurring).

## Terms

- `period`: range of time from start to end.
  - NOTE: When creating a period, instead of erroring if end is before start,
    order from earliest to latest.

```
+$  period
  $:  s=@da                  :: start
      e=@da                  :: end
  ==
```
