# Design

A big part of the agent is concerned with retrieval, and thereby efficient
storage, of events.

There three areas to be concerned with:

1. Storage of events.
2. Creation and modification of events.
3. Retrieval of events.

## Terms

- period: range of time from start to end.
  - NOTE: When creating a period, instead of erroring if end is before start,
    order from earliest to latest.

```
+$  period
  $:  s=@da                  :: start
      e=@da                  :: end
  ==
```

## 1. Storage of events


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

## 3. Retrieval of events

Urbit prefers CQRS in its design, which manifests in a pubsub pattern.

Retrieving events will involve subscribing to a path (wire?) of time in which
events should be delivered to a subscriber.

/year/month/day
/2020             => All events in year
/2020/5           => All events in month
/2020/5/25        => All events on day

Can also support ranges:

/2020/5/./2020/8/15 => All events from May 2020 to August 15th 2020.
