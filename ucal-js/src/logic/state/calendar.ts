import { Poke } from "@urbit/http-api"
import _ from "lodash"
import api, { scryNoShip } from "~/logic/api"

import {
  createState,
  createSubscription,
  pokeOptimisticallyN,
  reduceStateN,
} from "./base"

import Event, { EventForm } from "~/types/Event"
import Calendar, { DEFAULT_PERMISSIONS } from "~/types/Calendar"
import { getPermissionsChanges, permissionsMatch } from "~/types/Calendar"
import { CalendarViewState } from "~/views/CalendarView"

interface CalendarState {
  initialLoad: boolean
  createDefaultCalendar: boolean
  calendars: Calendar[]
  curTimezone: string
  events: Event[]
  getEvents: () => Promise<void>
  deleteEvent: (event: Event) => void
  saveEvent: (event: EventForm, update: boolean) => void
  getCalendars: () => Promise<void>
  saveCalendar: (data: CalendarViewState, update: boolean) => Promise<void>
  deleteCalendar: (calendar: Calendar) => Promise<boolean>
  toggleCalendar: (calendar: Calendar) => void
  setCurTimezone: (arg: string) => void
}

const useCalendarState = createState<CalendarState>(
  "Calendar",
  (set, get) => ({
    initialLoad: true,
    createDefaultCalendar: false,
    calendars: [],
    curTimezone: "utc",
    events: [],
    getEvents: async () => {
      const { calendars, curTimezone } = get()
      const path = `/~${window.ship}/timezone/${curTimezone}/events/all`
      const apiEvents = await api.scry({ app: "ucal-store", path })
      const filteredEvents = apiEvents
        .filter((re) => !!re)
        .map((e) => new Event(e))
      const updatedCalendars = Calendar.generateCalendars(
        calendars ? calendars : [],
        filteredEvents
      )
      set({ events: filteredEvents, calendars: updatedCalendars })
    },
    deleteEvent: async (event: Event): Promise<void> => {
      await api.poke({
        app: "ucal-store",
        mark: "ucal-action",
        json: {
          "delete-event": {
            "calendar-code": event.calendarCode,
            "event-code": event.eventCode,
          },
        },
      })
    },
    saveEvent: async (event: EventForm, update: boolean) => {
      for (const key in event) {
        if (event[key] === undefined) {
          delete event[key]
        }
      }
      await api.poke({
        app: "ucal-store",
        mark: "ucal-action",
        json: event.toExportFormat(update),
      })
    },
    getCalendars: async () => {
      const { events, createDefaultCalendar } = get()
      const apiCalendars = await api.scry({
        app: "ucal-store",
        path: `/~${window.ship}/calendars`,
      })
      if (apiCalendars.length == 0 && !createDefaultCalendar) {
        // If we don't find any calendars we should attempt to create a default
        get().saveCalendar(
          {
            title: "default",
            ...DEFAULT_PERMISSIONS,
            changes: [],
            reader: "",
            writer: "",
            acolyte: "",
          },
          false
        )
        set({ createDefaultCalendar: true })
      }
      const filteredCalendars = apiCalendars
        .filter((rc) => !!rc)
        .map((c) => new Calendar(c))
      const calendars = Calendar.generateCalendars(
        filteredCalendars,
        events ? events : []
      )
      set({ initialLoad: false, calendars })
    },
    saveCalendar: async (data: CalendarViewState, update = false) => {
      console.log(
        "SAVING:",
        JSON.stringify(Calendar.toExportFormat(data, update))
      )

      if (data.calendar?.title !== data.title) {
        await api.poke({
          app: "ucal-store",
          mark: "ucal-action",
          json: Calendar.toExportFormat(data, update),
        })
      }
      if (
        data.calendar?.permissions &&
        !permissionsMatch(data.calendar.permissions, { ...data })
      ) {
        const payload = {
          "change-permissions": { "calendar-code": data.calendar.calendarCode },
        }

        if (data.public !== data.calendar.permissions.public) {
          payload["change-permissions"][
            data.public ? "make-public" : "make-private"
          ] = null

          await api.poke({
            app: "ucal-store",
            mark: "ucal-action",
            json: payload,
          })
        } else {
          const changes = getPermissionsChanges(data.calendar, { ...data })

          changes.map((change) => {
            payload["change-permissions"]["change"] = change

            return api.poke({
              app: "ucal-store",
              mark: "ucal-action",
              json: payload,
            })
          })
        }
      }
    },
    deleteCalendar: async (calendar: Calendar) => {
      const confirmed = confirm(
        "Are you sure you want to delete this calendar? This cannot be undone."
      )

      if (confirmed) {
        // If the calendar is synced, we want to also delete it from %ucal-sync.
        // We do this before we send the delete to %ucal-store because the sync may
        // re-add it in between.
        const calendarIsSynced = await scryNoShip<boolean>(
          "ucal-sync",
          `/sync-active/${calendar.calendarCode}`
        )

        if (calendarIsSynced) {
          await api.poke({
            app: "ucal-sync",
            mark: "ucal-sync-action",
            json: {
              remove: {
                "calendar-code": calendar.calendarCode,
              },
            },
          })
        }

        await api.poke({
          app: "ucal-store",
          mark: "ucal-action",
          json: {
            "delete-calendar": {
              "calendar-code": calendar.calendarCode,
            },
          },
        })
      }

      return confirmed
    },
    toggleCalendar: (calendar: Calendar) => {
      const { calendars } = get()
      set({ calendars: calendars.map((c: Calendar) => c.toggle(calendar)) })
    },
    setCurTimezone: (curTimezone: string) => {
      set({ curTimezone })
    },
  }),
  ["initialLoad", "calendars", "curTimezone", "events"],
  [
    // (set, get) =>
    //   createSubscription('ucal', '/updates', (d) => {
    //     reduceStateN(get(), d, [reduce]);
    //   }),
    // (set, get) =>
    //   createSubscription('hark-graph-hook', '/updates', (j) => {
    //     const graphHookData = _.get(j, 'hark-graph-hook-update', false);
    //     if (graphHookData) {
    //       reduceStateN(get(), graphHookData, reduceGraph);
    //     }
    //   }),
    // (set, get) =>
    //   createSubscription('hark-group-hook', '/updates', (j) => {
    //     const data = _.get(j, 'hark-group-hook-update', false);
    //     if (data) {
    //       reduceStateN(get(), data, reduceGroup);
    //     }
    //   })
  ]
)

export default useCalendarState
