import Event from './Event'

export enum Timeframe {
  year = 'year',
  month = 'month',
  week = 'week',
  day = 'day',
}

export enum NavDirection {
  left = 'subtract',
  right = 'add',
}

export interface Permissions {
  readers: string[]
  writers: string[]
  acolytes: string[]
}

export default class Calendar {
  owner: string
  id: string
  title: string
  permissions: Permissions
  created: Date
  modified: Date
  events: Event[] = []

  constructor(data: any) {
    this.owner = data.owner
    this.id = data.id
    this.title = data.title
    this.permissions = data.permissions
    this.created = data.created
    this.modified = data.modified
  }

  static generateCalendars = (calendars: Calendar[], events: Event[]) : Calendar[] => {
    const all = new Map<string, Calendar | undefined>()

    calendars.forEach((calendar) => all.set(calendar.id, calendar))
    events.forEach((event) => {
      const updatedCalendar = all.get(event.calendarId)
      updatedCalendar?.events.push(event)
      all.set(event.calendarId, updatedCalendar)
    })

    const formattedCalendars : Calendar[] = []
    for (let item of all.values()) {
      if (item instanceof Calendar) {
        formattedCalendars.push(item)
      }
    }

    return formattedCalendars
  }
}

export interface ViewProps {
  calendars: Calendar[]
  displayDay: Date
  selectedDay: Date
  selectDay: (day: Date) => () => void
}

