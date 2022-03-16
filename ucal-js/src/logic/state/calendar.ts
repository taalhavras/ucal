// import { Poke } from '@urbit/http-api';
// import { patp2dec } from 'urbit-ob';
// import _ from 'lodash';
// import api from '~/logic/api';
// import { useCallback, useMemo } from 'react';

// import {
//   createState,
//   createSubscription,
//   pokeOptimisticallyN,
//   reduceStateN
// } from './base';
// import { reduce, reduceGraph, reduceGroup } from '../reducers/hark-update';

// import React, { createContext, useContext, useEffect, useState } from "react"
// import UrbitApi from "../logic/api"
// import Event, { EventForm } from "../types/Event"
// import Calendar, { DEFAULT_PERMISSIONS } from "../types/Calendar"
// import { CalendarViewState } from "../views/CalendarView"

// export const CalendarAndEventContext =
//   createContext<CalendarAndEventContextType>({
//     events: [],
//     setEvents: () => ({}),
//     calendars: [],
//     setCalendars: () => ({}),
//     curTimezone: "utc",
//     setCurTimezone: (arg: string) => ({}),
//   })

// export const CalendarAndEventProvider: React.FC = ({ children }) => {
//   const api = new UrbitApi()
//   const [events, setEvents] = useState<Event[]>([])
//   const [calendars, setCalendars] = useState<Calendar[]>([])
//   const [initialLoad, setInitialLoad] = useState(true)
//   //  Determine if we should be creating a default calendar. If we ever get
//   //  a calendars response w/no calendars we will try to create a default.
//   const [createDefaultCalendar, setCreateDefaultCalendar] = useState(false)
//   //  The current timezone - defaults to UTC.
//   const [curTimezone, setCurTimezone] = useState("utc")

//   const getEvents = async (): Promise<void> => {
//     const path = "/timezone/" + curTimezone + "/events/all"
//     const apiEvents = await api.scry<any>("ucal-store", path)
//     const filteredEvents = apiEvents
//       .filter((re) => !!re)
//       .map((e) => new Event(e))
//     setEvents(filteredEvents)
//     const updatedCalendars = Calendar.generateCalendars(
//       calendars ? calendars : [],
//       filteredEvents
//     )
//     setCalendars(updatedCalendars)
//   }

//   const deleteEvent = async (event: Event): Promise<void> => {
//     await api.action("ucal-store", "ucal-action", {
//       "delete-event": {
//         "calendar-code": event.calendarCode,
//         "event-code": event.eventCode,
//       },
//     })
//   }

//   const saveEvent = async (
//     event: EventForm,
//     update: boolean
//   ): Promise<void> => {
//     for (const key in event) {
//       if (event[key] === undefined) {
//         delete event[key]
//       }
//     }
//     console.log("SAVING:", JSON.stringify(event.toExportFormat(update)))
//     await api.action("ucal-store", "ucal-action", event.toExportFormat(update))
//   }

//   const getCalendars = async (): Promise<void> => {
//     const apiCalendars = await api.scry<any>("ucal-store", "/calendars")
//     if (apiCalendars.length == 0 && !createDefaultCalendar) {
//       // If we don't find any calendars we should attempt to create a default
//       setCreateDefaultCalendar(true)
//     }
//     const filteredCalendars = apiCalendars
//       .filter((rc) => !!rc)
//       .map((c) => new Calendar(c))
//     setCalendars(
//       Calendar.generateCalendars(filteredCalendars, events ? events : [])
//     )
//     setInitialLoad(false)
//     return apiCalendars
//   }

//   const saveCalendar = async (
//     data: CalendarViewState,
//     update = false
//   ): Promise<void> => {
//     console.log(
//       "SAVING:",
//       JSON.stringify(Calendar.toExportFormat(data, update))
//     )

//     if (data.calendar?.title !== data.title) {
//       await api.action(
//         "ucal-store",
//         "ucal-action",
//         Calendar.toExportFormat(data, update)
//       )
//     }
//     if (data.calendar && data.calendar?.permissions?.public !== data.public) {
//       const payload = {
//         "change-permissions": { "calendar-code": data.calendar.calendarCode },
//       }
//       payload["change-permissions"][
//         data.public ? "make-public" : "make-private"
//       ] = null

//       await api.action("ucal-store", "ucal-action", payload)
//     }
//   }

//   const saveInitialCalendar = async () => {
//     return saveCalendar({ title: "default", ...DEFAULT_PERMISSIONS })
//   }

//   const deleteCalendar = async (calendar: Calendar): Promise<boolean> => {
//     const confirmed = confirm(
//       "Are you sure you want to delete this calendar? This cannot be undone."
//     )

//     if (confirmed) {
//       await api.action("ucal-store", "ucal-action", {
//         "delete-calendar": {
//           "calendar-code": calendar.calendarCode,
//         },
//       })
//     }

//     return confirmed
//   }

//   const toggleCalendar = (calendar: Calendar) => {
//     setCalendars(calendars.map((c: Calendar) => c.toggle(calendar)))
//   }

//   const { Provider } = CalendarAndEventContext

//   useEffect(() => {
//     getEvents()
//     setInitialLoad(true)
//   }, [])

//   // In additiona to polling for all the events when this loads,
//   // we want to do so every time the timezone changes.
//   useEffect(() => {
//     getEvents()
//   }, [curTimezone])

//   useEffect(() => {
//     if (!!calendars && !!events && calendars.length < 1) {
//       getCalendars()
//       setInitialLoad(true)
//     }
//   }, [calendars, events])

//   useEffect(() => {
//     let requestInProgress = false
//     const fcn = async () => {
//       if (createDefaultCalendar && !requestInProgress) {
//         requestInProgress = true
//         try {
//           await saveInitialCalendar()
//           setCreateDefaultCalendar(false)
//           const cals = await getCalendars()
//           setCalendars(Calendar.generateCalendars(cals, []))
//         } catch (error) {
//           console.log({ error })
//         }
//       }
//       return () => {
//         requestInProgress = false
//       }
//     }

//     fcn()
//   }, [createDefaultCalendar])

//   return (
//     <Provider
//       value={{
//         events,
//         setEvents,
//         getEvents,
//         deleteEvent,
//         saveEvent,
//         calendars,
//         setCalendars,
//         getCalendars,
//         saveCalendar,
//         deleteCalendar,
//         toggleCalendar,
//         curTimezone,
//         setCurTimezone,
//       }}
//     >
//       {!!events && !!calendars && !initialLoad ? children : "Loading..."}
//     </Provider>
//   )
// }

// export const useCalendarsAndEvents = () => useContext(CalendarAndEventContext)

// interface CalendarState {
//   calendars: Calendar[]
//   curTimezone: string
//   events: Event[]
//   setEvents: (arg: Event[]) => void
//   getEvents: () => Promise<void>
//   deleteEvent: (event: Event) => void
//   saveEvent: (event: EventForm, update: boolean) => void
//   setCalendars: (arg: Calendar[]) => void
//   getCalendars: () => Promise<void>
//   saveCalendar: (data: CalendarViewState, update: boolean) => Promise<void>
//   deleteCalendar: (calendar: Calendar) => Promise<boolean>
//   toggleCalendar: (calendar: Calendar) => void
//   setCurTimezone: (arg: string) => void
// }

// const useCalendarState = createState<CalendarState>(
//   'Hark',
//   (set, get) => ({
//     archive: new BigIntOrderedMap<Timebox>(),
//     doNotDisturb: false,
//     unreadNotes: [],
//     poke: async (poke: Poke<any>) => {
//       await pokeOptimisticallyN(useCalendarState, poke, [reduce]);
//     },
//     readGraph: async (graph: string) => {
//       const prefix = `/graph/${graph.slice(6)}`;
//       let counts = [] as string[];
//       let eaches = [] as [string, string][];
//       Object.entries(get().unreads).forEach(([path, unreads]) => {
//         if (path.startsWith(prefix)) {
//           if(unreads.count > 0) {
//             counts.push(path);
//           }
//           unreads.each.forEach(unread => {
//             eaches.push([path, unread]);
//           });
//         }
//       });
//       get().set(draft => {
//         counts.forEach(path => {
//           draft.unreads[path].count = 0;
//         });
//         eaches.forEach(([path, each]) => {
//           draft.unreads[path].each = [];
//         });
//       });
//       await Promise.all([
//         ...counts.map(path => markCountAsRead({ desk: window.desk, path })),
//         ...eaches.map(([path, each]) => markEachAsRead({ desk: window.desk, path }, each))
//       ].map(pok => api.poke(pok)));
//     },
//     readGroup: async (group: string) => {
//       const graphs =
//         _.pickBy(useMetadataState.getState().associations.graph, a => a.group === group);
//       await Promise.all(Object.keys(graphs).map(get().readGraph));
//     },
//     readCount: async (path) => {
//       const poke = markCountAsRead({ desk: (window as any).desk, path });
//       await pokeOptimisticallyN(useCalendarState, poke, [reduce]);
//     },
//     opened: async () => {
//       reduceStateN(get(), { opened: null }, [reduce]);
//       await api.poke(opened);
//     },
//     archiveNote: async (bin: HarkBin, lid: HarkLid) => {
//       const poke = archive(bin, lid);
//       get().set((draft) => {
//         const key = 'seen' in lid ? 'seen' : 'unseen';
//         const binId = harkBinToId(bin);
//         delete draft[key][binId];
//       });
//       await api.poke(poke);
//     },
//     getMore: async (): Promise<boolean> => {
//       const state = get();
//       const oldSize = state.archive?.size || 0;
//       const offset = decToUd(
//         state.archive?.peekSmallest()?.[0].toString()
//         || unixToDa(Date.now() * 1000).toString()
//       );
//       const update = await api.scry({
//         app: 'ucal',
//         path: `/recent/inbox/${offset}/5`
//       });
//       reduceStateN(useCalendarState.getState(), update, [reduce]);
//       return get().archive?.size === oldSize;
//     },
//     unseen: {},
//     seen: {},
//     notificationsCount: 0,
//     notificationsGraphConfig: {
//       watchOnSelf: false,
//       mentions: false,
//       watching: []
//     },
//     notificationsGroupConfig: [],
//     unreads: {}
//   }),
//   [
//     'seen',
//     'unseen',
//     'archive',
//     'unreads',
//     'notificationsCount'
//   ],
//   [
//     (set, get) =>
//       createSubscription('ucal', '/updates', (d) => {
//         reduceStateN(get(), d, [reduce]);
//       }),
//     (set, get) =>
//       createSubscription('hark-graph-hook', '/updates', (j) => {
//         const graphHookData = _.get(j, 'hark-graph-hook-update', false);
//         if (graphHookData) {
//           reduceStateN(get(), graphHookData, reduceGraph);
//         }
//       }),
//     (set, get) =>
//       createSubscription('hark-group-hook', '/updates', (j) => {
//         const data = _.get(j, 'hark-group-hook-update', false);
//         if (data) {
//           reduceStateN(get(), data, reduceGroup);
//         }
//       })
//   ]
// );

// export const emptyHarkStats = () => ({
//       last: 0,
//       count: 0,
//       each: []
//     });

// export function useHarkDm(ship: string) {
//   return useCalendarState(
//     useCallback(
//       (s) => {
//         const key = `/graph/~${window.ship}/dm-inbox/${patp2dec(ship)}`;
//         return s.unreads[key] || emptyHarkStats();
//       },
//       [ship]
//     )
//   );
// }

// export function useHarkStat(path: string) {
//   return useCalendarState(
//     useCallback(s => s.unreads[path] || emptyHarkStats(), [path])
//   );
// }

// export function selHarkGraph(graph: string) {
//   const [,, ship, name] = graph.split('/');
//   const path = `/graph/${ship}/${name}`;
//   return (s: CalendarState) => (s.unreads[path] || emptyHarkStats());
// }

// export function useHarkGraph(graph: string) {
//   const sel = useMemo(() => selHarkGraph(graph), [graph]);
//   return useCalendarState(sel);
// }

// export function useHarkGraphIndex(graph: string, index: string) {
//   const [, ship, name] = useMemo(() => graph.split('/'), [graph]);
//   return useCalendarState(
//     useCallback(s => s.unreads[`/graph/${ship}/${name}/index`], [
//       ship,
//       name,
//       index
//     ])
//   );
// }

// export default useCalendarState;
