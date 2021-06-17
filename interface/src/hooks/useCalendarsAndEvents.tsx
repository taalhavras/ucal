import React, { createContext, useContext, useEffect, useState } from "react"
import UrbitApi from "../logic/api"
import Event, { EventForm } from "../types/Event"
import Calendar, { DEFAULT_PERMISSIONS } from "../types/Calendar"
import { CalendarViewState } from "../views/CalendarView"

type CalendarAndEventContextType = {
  events: Event[]
  setEvents: (arg: Event[]) => void
  getEvents?: () => Promise<void>
  deleteEvent?: (event: Event) => void
  saveEvent?: (event: EventForm, update: boolean) => void
  calendars: Calendar[]
  setCalendars: (arg: Calendar[]) => void
  getCalendars?: () => Promise<void>
  saveCalendar?: (data: CalendarViewState, update: boolean) => Promise<void>
  deleteCalendar?: (calendar: Calendar) => Promise<boolean>
  toggleCalendar?: (calendar: Calendar) => void
}

export const CalendarAndEventContext =
  createContext<CalendarAndEventContextType>({
    events: [],
    setEvents: () => ({}),
    calendars: [],
    setCalendars: () => ({}),
  })

export const CalendarAndEventProvider: React.FC = ({ children }) => {
  const api = new UrbitApi()
  const [events, setEvents] = useState<Event[]>([])
  const [calendars, setCalendars] = useState<Calendar[]>([])
  const [initialLoad, setInitialLoad] = useState(false)

  const getEvents = async (): Promise<void> => {
    const apiEvents = await api.scry<any>("ucal-store", "/events")
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
    await api.action("ucal-store", "ucal-action", {
      "delete-event": {
        "calendar-code": event.calendarCode,
        "event-code": event.eventCode,
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
    console.log("SAVING:", JSON.stringify(event.toExportFormat(update)))
    await api.action("ucal-store", "ucal-action", event.toExportFormat(update))
  }

  const getCalendars = async (): Promise<void> => {
    const apiCalendars = await api.scry<any>("ucal-store", "/calendars")
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
      await api.action(
        "ucal-store",
        "ucal-action",
        Calendar.toExportFormat(data, update)
      )
    }
    if (data.calendar && data.calendar?.permissions?.public !== data.public) {
      const payload = {
        "change-permissions": { "calendar-code": data.calendar.calendarCode },
      }
      payload["change-permissions"][
        data.public ? "make-public" : "make-private"
      ] = null

      await api.action("ucal-store", "ucal-action", payload)
    }
  }

  const saveInitialCalendar = async () => {
    await saveCalendar({ title: "default", ...DEFAULT_PERMISSIONS })
    await getCalendars()
  }

  const deleteCalendar = async (calendar: Calendar): Promise<boolean> => {
    const confirmed = confirm(
      "Are you sure you want to delete this calendar? This cannot be undone."
    )

    if (confirmed) {
      await api.action("ucal-store", "ucal-action", {
        "delete-calendar": {
          "calendar-code": calendar.calendarCode,
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

  useEffect(() => {
    if (!!calendars && !!events && calendars.length < 1) {
      getCalendars()
    }
  }, [calendars])

  useEffect(() => {
    if (!!calendars && !!events && calendars.length < 1 && !initialLoad) {
      try {
        saveInitialCalendar()
      } catch (error) {
        console.log({ error })
      }
    }
  }, [calendars, initialLoad])

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
      }}
    >
      {!!events && !!calendars && !initialLoad ? children : "Loading..."}
    </Provider>
  )
}

export const useCalendarsAndEvents = () => useContext(CalendarAndEventContext)
