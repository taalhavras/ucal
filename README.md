# Urbit Calendar

[![awesome urbit badge](https://img.shields.io/badge/~-awesome%20urbit-lightgrey)](https://github.com/urbit/awesome-urbit)

![screenshot](https://archiv.nyc3.digitaloceanspaces.com/littel-wolfur/2021.3.03..16.28.48-screen.jpg)

## Usage
TODO explain how to use https://gist.github.com/taalhavras/91ccf630f58c2a8e2e757271ba3f54bd

Clone the repository and then create a .urbitrc in the root that looks like the .urbitrc-sample file. It should look like
```
module.exports = {
  URBIT_PIERS: [
    "/path/to/first/pier/zod/home",
    "/path/to/other/pier/nel/home"
  ],
  URL: 'http://localhost:*port of running ship*'
};

```
Then run `yarn` and `yarn build` from the project root to copy the files into the target pier(s). Finally, `|mount %` and `|start %ucal-store` to get the app running. Run `|start %calendar` to activate the UI.

### ucal-store pokes
The best documentation for these is the source code for `action` in `sur/ucal-store.hoon`. They're all pretty straightforward to use, though there are some convenience generators for calendar/event creation we'll talk about later.

Here's a table of how JSON should be formatted for each poke
| Poke                | Json                                                                                                                                                                                                                                                                                                                                                                              |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| %create-calendar    | `{'create-calendar': {'calendar-code': 'abcd-efgh', 'title': 'my-cal'}}`|
| %update-calendar    | <pre>{'update-calendar': {'calendar-code': 'abcd-efgh',<br />'title': 'new-title' // optional, though pointless not to include   } }<pre>|
| %delete-calendar    | <pre>{'delete-calendar': {'calendar-code': 'some-code'}}<pre>|
| %create-event       | <pre>{'create-event': {'calendar-code': 'some-code', <br />  'event-code': 'event-code', // optional <br /> 'organizer': '~zod', <br /> 'title': 'my-event',<br/> 'desc': 'some-description', // optional <br /> 'tzid': 'utc', <br /> 'location': some-location, // optional <br /> 'when': some-moment, <br /> 'era': some-era, // optional <br /> 'invited': ['~nel', '~bus'] // optional - no invites if not included } }<pre>|
| %update-event       | <pre>{'update-event': {'calendar-code': 'some-code', <br />'event-code': 'event-code',     <br />'title': 'new-title', // optional     <br />'desc': 'some-description', // optional, can specify null     <br />'location': some-location, // optional, can specify null     <br />'when': some-moment, // optional     <br />'era': some-era, // optional, can specify null     <br />'tzid': 'utc' // optional   } }<pre> |
| %delete-event       | <pre>{'delete-event': {'calendar-code': 'some-code', 'event-code': 'event-code'   } }<pre>|
| %change-rsvp        | <pre>{'change-rsvp': {'calendar-code': 'some-code', <br />'event-code': 'event-code',  <br />'who': '~zod',  <br />'invite': some-bool   } }<pre>                                                                                                                                                                                           |
| %import-from-ics    | <pre>{'import-from-ics': {'path': 'some-path', // or <br />'data: 'some-ics-data', <br />'calendar-code:' 'some-code' // optional, a random code will be chosen if this isn't specified   } }<pre>                                                                                                                                                                                                                                                                                                                               |
| %change-permissions | <pre>{'change-permissions': {'calendar-code': 'some-code',<br />// now we have ONE of the following     <br />// 1.<br />'change' : {'who': 'some-ship', 'role': 'some-role'} // role is either reader, writer, or acolyte<br />// 2.<br />'make-public': null     <br />// 3.<br />'make-private': null   } }<pre>                                                                                                     |


The general format of a cell type in JSON is a dictionary of field name to value.
Tagged unions (types created with `$%`) will have a single key (the tag) mapped to another
object containing the fields in that specific variant.

The `calendar-permissions` type is an exception to the above formatting: In json it looks like
```
{
  "readers" : ["~zod" "~nel"],
  "writers" : [],
  "acolytes": ["~bus"],
  "public" : false
}
```
where `readers`, `writers` and `acolytes` are arrays of ships and `public` is a boolean.
The source code for json serialization/deserialization is in `lib/ucal/util.hoon`, consult that file
for the specifics of how any type is serialized/deserialized.

Some other types mentioned above that must be parsed from json are below. <br />
moment:
```
{ 'period' : {'start': start-time, 'end': end-time} }
```
<br />

location:
<pre>
{
    'address': "some-address",
    // geo is optional
    'geo': {'lat': 23.2, 'lon': 54.4}
}
</pre>
<br />

era:
<pre>
{
  'type': {
    // 1.
    'until': some-date
    // 2.
    'instances': 10
    // 3.
    'infinite': null
  },
  'interval': 23,
  'rrule': {
     // 1.
     'daily': null
     // 2.
     'weekly': ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
     // 3.
     'monthly': {
       // 1.
       'on': null
       // 2.
       'weekday': 'wed'
     }
     // 4.
     'yearly': null
  }
}
</pre>

### ucal-store scrys
Note: All paths below should be suffixed with a mark - either `noun` or `json` will work (for noun and json results respectively). You can also use the `ics` mark for the %calendar-and-events scry as well as any other scry that returns a single calendar, single event, or list of events. This mark produces an @t of the data parsed into the ICS file format as specified by [RFC 5545](https://datatracker.ietf.org/doc/html/rfc5545). The most useful scry here is %calendar-and-events - the others are mostly supported because it was easy to add such support.
`cal-code` and `event-code` are unique per calendar/event and are just `@tas`s (they're just uuids). For the scry for events in range, start and end are `@da`s. `ship` is an `@p` whose almanac (a collection of calendars and events) we're examining.
| Path                                     | Return type                                  | Notes                                                                                                                                                                                                                                                                                                                   |
|------------------------------------------|----------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `%x ship %calendars`                            | (list calendar)                              | all calendars                                                                                                                                                                                                                                                                                                           |
| `%x ship %events`                               | (list event)                                 | all events                                                                                                                                                                                                                                                                                                              |
| `%x ship %calendars cal-code`                   | calendar                                     | a specific calendar                                                                                                                                                                                                                                                                                                     |
| `%x ship %events %specific cal-code event-code` | event                                        | a specific event on a specific calendar                                                                                                                                                                                                                                                                                 |
| `%x ship %events %bycal cal-code`               | (list event)                                 | all events on a specific calendar                                                                                                                                                                                                                                                                                       |
| `%x ship %calendar-and-events cal-code`         | [calendar (list event)]                      | calendar + all events on that calendar                                                                                                                                                                                                                                                                                  |
| `%x ship %events %inrange cal-code start end`   | [(list event) (list projected-event)]        | produces two lists if a calendar with the specified code exits, unit otherwise. the  (list event) is exactly what you'd expect and the (list projected-event) contains specific instances of recurring events found in the target range. the convention is start then end, but they can be supplied in reverse as well. |
|  `%x %host cal-code event-code`    |  @p  |  the ship hosting a particular event we're invited to |

#### Invitation scrys
The above scrys can also be used to retrieve information about events you've been invited to. You won't have access to calendar data for these events (unless you separately have access to it), but by using `%invited-to` instead of an `@p` in the path all scries that produce events will get you events you've been invited to. These scries are the only way to see these events if you don't have access to the calendars they're hsoted on.

### Timezones in ucal
All scries that produce events can have `/timezone/ZONE_NAME` included after the ship. This means that the events produced wil have
times adjusted to the specified timezone. Some examples with EST as the timezone of choice:
```
/gx/~zod/events/specific/abcd-efgh/hijk-lmno/noun -> /gx/~zod/timezone/EST/events/specific/abcd-efgh/hijk-lmno/noun
/gx/~zod/events/bycal/abcd-efgh/noun -> /gx/~zod/timezone/EST/events/bycal/abcd-efgh/noun
/gx/~zod/events/inrange/abcd-efgh/~2020.1.1/~2020.1.3/noun -> /gx/~zod/timezone/EST/events/inrange/abcd-efgh/~2020.1.1/~2020.1.3/noun
```
You'll need to run `timezone-store`on your ship with some imported data for this to work. See the `timezone-store` section below for more details on how to set this up.

### ucal-pull-hook pokes
| Poke                 | Json                                                                                                                                                                  |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| %query-cals          | <pre>{'query-cals': {'who': 'some-ship'}}<pre> |
| %invitation-response | <pre>{'invitation-response': {<br>    'calendar-code': 'some-code',<br>    'event-code': 'some-code',<br>    'status': 'yes' // either 'yes', 'no', or 'maybe'<br>  }<br>}<pre> |

Again, the best documentation for these is the source (specifically the `++on-poke` arm in `ucal-pull-hook.hoon`) but here's an overview. `%invitation-response` is hopefully fairly obvious - it just sends an rsvp for a specified event. `%query-cals` sends a request to a given ship for all the calendar metadata that we (the sender) have access to. Responses to this poke can be accessed via a scry (documented below).

### ucal-pull-hook scrys
These scries can also be suffixed with either noun or json, depending on what you want.
| Scry              | Return type     | Notes                                             |
|-------------------|-----------------|---------------------------------------------------|
| `%x %metadata @p` | (list metadata) | metadata are [owner=@p title=cord =calendar-code] |

### Creating a calendar/event with a generator
Run `:ucal-store|create-calendar some-title-cord` to create a calendar. The same syntax can be used for creating events, with `create-event` instead (there's a different set of arguments). The generators can be found in `urbit/gen/ucal-store` and an explanation of this syntax is [here.](https://github.com/timlucmiptev/gall-guide/blob/master/generators.md)

### Other useful generators
`+all-calendars, =who (unit @p), =local flag` : Dumps a list of metadata (`[owner title code]` tuples) so you can quickly see what calendars are in the store for a given ship (defaults to current ship if not specified). If local is specified to be false, queries the pull-hook instead. Useful in conjunction with...

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

### timezone-store
Timezones are handled with the help of a separate store - `timezone-store` to be exact. The store is itself fairly simple - it
has one poke and two main scrys. It's built to handle the [tz database](https://github.com/eggert/tz) - a canonical source for all timezone data, past and present.
Timezones are obviously important to `ucal`, but they will certainly be important to other applications as well which is why this
is a wholly separate store. Applications using this will probably be interested in `lib/iana/*`, specifically `lib/iana/conversion.hoon`.
To use `timezone-store` you'll need to populate it with some data. You can either clone the repo linked above or copy specific files
into your urbit. Which files? You'll want the ones roughly named for continents (i.e. `northamerica`, `asia`, etc.)
Note that since the files in question don't have extensions, you'll need to rename them (just adding `.txt` is sufficient). There
is a script in this repo that does this - run `import-timezones.sh DIR` to import all the files into the supplied directory.
Once you've imported the files you want into your urbit you can import them into `timezone-store` with
```
:timezone-store &timezone-store-action [%import-files ~[/path/to/first/file /path/to/second/file]]
```
If an import contains data previously in the store, the old data is overwritten. You can also reset the store with
```
:timezone-store %reset-state
```
if you want a truly blank slate.

### Invitations
To invite/uninvite ships from a calendar use the `change-rsvp` poke on `ucal-store` - this is also equivalent to creating an event with those ships in the invited set. To see what events you are invited to you can use any scries that produce events from the above table, using `%invited-to` in the path instead of a ship name. To respond to invitations, poke your local `ucal-pull-hook` (see the pull-hook section for the details).

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

### ICS integrations
We briefly covered importing calendars from .ics files above (see the %import-from-ics poke) but to conveniently import a calendar from a URL you can use `-fetch-ics "some-url"` - see `ted/fetch-ics.hoon` for the details!

For a more robust importing experience look to `ucal-sync`. This app interacts with `ucal-store` in order to periodically "sync" calendars from urls. Please see `sur/ucal-sync.hoon` for the pokes you can send this app - the interface is pretty self explanatory. Once imported, the calendars should be treated as a read-only calendar inside of ucal. While mechanically you can still modify them by poking the store these changes will be lost when the calendar is next syncd. Other ships can still subscribe to the calendar and see updates as the calendar referred to by the url changes. If you ever stop the sync this restriction on modifying the calendar will stop applying - though if that's your end goal you should just use `fetch-ics` instead.

See the section on scries for info on converting to ics (in particular discussion of the `ics` mark in the particular) but calendars can also be exposed as ics files via GET requests. This is already [baked in to how scries work](https://urbit.org/docs/arvo/eyre/external-api-ref#scry) but `ucal-store` also exposes a separate interface to allow GET requests for any public calendars in the store. For example, `curl -i localhost:8080/ucal-ics/~zod/obzf-gpup` would retrieve the calendar and associated events for a calendar owned by `~zod` with code `obzf-gpup` that a local ship knows about (note that this is _not_ necessarily a calendar created by `~zod` - it can also be a public calendar that `~zod` has subscribed to). The hope with this feature is to support integrating ucal directly with i.e. Google Calendar/Outlook as they both allow you to import calendars via a url.

## Current Roadmap
These are the current big tasks to undertake (in no particular order).

1. almanac update to use ordered map (and potentially implementing an interval tree)
2. invites
3. more ph tests (sadly broken atm)


### almanac update
branch: none

The data structure used to currently store events (the almanac) is naively implemented and can be improved. I think there's an ordered map somewhere in the la/graph-store branch of the main urbit repo (++mop) that we may be able to use here. It might also be worth implementing an [Interval Tree](https://en.wikipedia.org/wiki/Interval_tree) as this seems to be the most efficient data structure for these types of queries.

### recurrent event invites
branch: event-invites

Currently invites are implemented naively for recurring events (one invite for all events). These should certainly be maintained per event.

### pH Testing (broken as of network breach)
branch: none

We have tests to verify calendar/event creation, destruction, and updates. There's also a test that demonstrates the hooks in use - subscriptions to calendars, updates propagating, and eventually stopping when the calendar is deleted. As more functionality (i.e. invites) is added, more tests will be needed (you can't have too many tests right?).

## Interface (front-end)

Created from tlon's [create-landscape-app](https://github.com/urbit/create-landscape-app).

### Development

0. Ensure your have followed installation instructions above (`yarn run build`)

1. On your Urbit ship, if you haven't already, mount your pier to Unix with `|mount %`.

2. Once you're up and running, your application lives in the `src` folder; `src` uses [React](https://reactjs.org) to render itself -- you'll want a basic foothold with it first.

3. Run `npm run serve-interface` to serve a dev server environment with hot reloading at `localhost:9000`.
