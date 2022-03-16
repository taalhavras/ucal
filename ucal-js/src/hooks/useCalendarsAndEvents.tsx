import React, { createContext, useContext, useEffect, useState } from "react"
import Event, { EventForm } from "../types/Event"
import Calendar, { DEFAULT_PERMISSIONS } from "../types/Calendar"
import { CalendarViewState } from "../views/CalendarView"
import api, { scryNoShip } from "../logic/api/index"
import { Col, LoadingSpinner } from "@tlon/indigo-react"

type CalendarAndEventContextType = {
  events: Event[]
  setEvents: (arg: Event[]) => void
  getEvents?: () => Promise<void>
  deleteEvent?: (event: Event) => void
  saveEvent?: (event: EventForm, update: boolean) => void
  calendars: Calendar[]
  setCalendars: (arg: Calendar[]) => void
  getCalendars?: () => Promise<Calendar[]>
  saveCalendar?: (data: CalendarViewState, update: boolean) => Promise<void>
  deleteCalendar?: (calendar: Calendar) => Promise<boolean>
  toggleCalendar?: (calendar: Calendar) => void
  curTimezone: string
  setCurTimezone: (arg: string) => void
}

export const CalendarAndEventContext =
  createContext<CalendarAndEventContextType>({
    events: [],
    setEvents: () => ({}),
    calendars: [],
    setCalendars: () => ({}),
    curTimezone: "utc",
    setCurTimezone: (arg: string) => ({}),
  })

export const CalendarAndEventProvider: React.FC = ({ children }) => {
  const [events, setEvents] = useState<Event[]>([])
  const [calendars, setCalendars] = useState<Calendar[]>([])
  const [initialLoad, setInitialLoad] = useState(true)
  //  Determine if we should be creating a default calendar. If we ever get
  //  a calendars response w/no calendars we will try to create a default.
  const [createDefaultCalendar, setCreateDefaultCalendar] = useState(false)
  //  The current timezone - defaults to UTC.
  const [curTimezone, setCurTimezone] = useState("utc")

  const getEvents = async (): Promise<void> => {
    const path = `/~${window.ship}/timezone/${curTimezone}/events/all`
    const apiEvents = await api.scry({ app: "ucal-store", path })
    const filteredEvents = apiEvents
      .filter((re) => !!re)
      .map((e) => new Event(e))
    setEvents(filteredEvents)
    const updatedCalendars = Calendar.generateCalendars(
      calendars ? calendars : [],
      filteredEvents
    )
    setCalendars(updatedCalendars)
  }

  const deleteEvent = async (event: Event): Promise<void> => {
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
  }

  const saveEvent = async (
    event: EventForm,
    update: boolean
  ): Promise<void> => {
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
  }

  const getCalendars = async (): Promise<any[]> => {
    const apiCalendars = await api.scry({
      app: "ucal-store",
      path: `/~${window.ship}/calendars`,
    })
    if (apiCalendars.length == 0 && !createDefaultCalendar) {
      // If we don't find any calendars we should attempt to create a default
      setCreateDefaultCalendar(true)
    }
    const filteredCalendars = apiCalendars
      .filter((rc) => !!rc)
      .map((c) => new Calendar(c))
    setCalendars(
      Calendar.generateCalendars(filteredCalendars, events ? events : [])
    )
    setInitialLoad(false)
    return apiCalendars
  }

  const saveCalendar = async (
    data: CalendarViewState,
    update = false
  ): Promise<void> => {
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
    if (data.calendar && data.calendar?.permissions?.public !== data.public) {
      const payload = {
        "change-permissions": { "calendar-code": data.calendar.calendarCode },
      }
      payload["change-permissions"][
        data.public ? "make-public" : "make-private"
      ] = null

      await api.poke({
        app: "ucal-store",
        mark: "ucal-action",
        json: payload,
      })
    }
  }

  const saveInitialCalendar = async () => {
    return saveCalendar({ title: "default", ...DEFAULT_PERMISSIONS })
  }

  const deleteCalendar = async (calendar: Calendar): Promise<boolean> => {
    const confirmed = confirm(
      "Are you sure you want to delete this calendar? This cannot be undone."
    )

    if (confirmed) {
      // If the calendar is synced, we want to also delete it from %ucal-sync.
      // We do this before we send the delete to %ucal-store because the sync may
      // re-add it in between.
      const calendarIsSynced = await scryNoShip<boolean>("ucal-sync", `/sync-active/${calendar.calendarCode}`)

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
  }

  const toggleCalendar = (calendar: Calendar) => {
    setCalendars(calendars.map((c: Calendar) => c.toggle(calendar)))
  }

  const { Provider } = CalendarAndEventContext

  useEffect(() => {
    getEvents()
    setInitialLoad(true)
  }, [])

  // In additiona to polling for all the events when this loads,
  // we want to do so every time the timezone changes.
  useEffect(() => {
    getEvents()
  }, [curTimezone])

  useEffect(() => {
    if (!!calendars && !!events && calendars.length < 1) {
      getCalendars()
      setInitialLoad(true)
    }
  }, [calendars, events])

  useEffect(() => {
    let requestInProgress = false
    const fcn = async () => {
      if (createDefaultCalendar && !requestInProgress) {
        requestInProgress = true
        try {
          await saveInitialCalendar()
          setCreateDefaultCalendar(false)
          const cals = await getCalendars()
          setCalendars(Calendar.generateCalendars(cals, []))
        } catch (error) {
          console.log({ error })
        }
      }
      return () => {
        requestInProgress = false
      }
    }

    fcn()
  }, [createDefaultCalendar])

  return (
    <Provider
      value={{
        events,
        setEvents,
        getEvents,
        deleteEvent,
        saveEvent,
        calendars,
        setCalendars,
        getCalendars,
        saveCalendar,
        deleteCalendar,
        toggleCalendar,
        curTimezone,
        setCurTimezone,
      }}
    >
      {!!events && !!calendars && !initialLoad ? (
        children
      ) : (
        <Col
          alignItems="center"
          justifyContent="center"
          height="100vh"
          width="100vw"
        >
          <LoadingSpinner />
        </Col>
      )}
    </Provider>
  )
}

export const useCalendarsAndEvents = () => useContext(CalendarAndEventContext)
