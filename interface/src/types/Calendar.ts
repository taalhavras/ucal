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
  calendar_code: string
  title: string
  permissions: Permissions
  created: Date
  modified: Date
  events: Event[] = []

  constructor(data: any) {
    console.log(data)
    this.owner = data.owner
    this.calendar_code = data['calendar-code']
    this.title = data.title
    this.permissions = data.permissions
    this.created = data.created
    this.modified = data.modified
  }

  static generateCalendars = (calendars: Calendar[], events: Event[]) : Calendar[] => {
    const all = new Map<string, Calendar | undefined>()

    calendars.forEach((calendar) => all.set(calendar.calendar_code, calendar))
    events.forEach((event) => {
      const updatedCalendar = all.get(event.calendar_code)
      updatedCalendar?.events.push(event)
      all.set(event.calendar_code, updatedCalendar)
    })

    console.log(all)

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
  location: string
}

