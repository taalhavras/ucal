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
  calendarCode: string
  title: string
  permissions: Permissions
  created: Date
  modified: Date
  events: Event[] = []
  active = true

  constructor(data: any) {
    this.owner = data.owner
    this.calendarCode = data['calendar-code']
    this.title = data.title
    this.permissions = data.permissions
    this.created = data['date-created'] && new Date(data['date-created'])
    this.modified = data['last-modified'] && new Date(data['last-modified'])
  }

  clearEvents = () => {
    this.events = []
    return this
  }

  static generateCalendars = (calendars: Calendar[], events: Event[]) : Calendar[] => {
    const all = new Map<string, Calendar | undefined>()

    calendars.forEach((calendar) => all.set(calendar.calendarCode, calendar.clearEvents()))
    events.forEach((event) => {
      const updatedCalendar = all.get(event.calendarCode)
      updatedCalendar?.events.push(event)
      all.set(event.calendarCode, updatedCalendar)
    })

    const formattedCalendars : Calendar[] = []
    for (let item of all.values()) {
      if (item instanceof Calendar) {
        formattedCalendars.push(item)
      }
    }

    return formattedCalendars
  }

  static getActiveEvents = (calendars: Calendar[]) : Event[] => {
    return calendars.filter((c) => c.active)
      .reduce((acc: Event[], cur: Calendar) => acc.concat(cur.events), [])
  }
}

export interface ViewProps {
  calendars: Calendar[]
  displayDay: Date
  selectedDay: Date
  selectDay: (day: Date) => (event: React.MouseEvent<HTMLElement>) => void
  userLocation: string
  goToEvent: (calendarCode: string, eventCode: string) => (event: React.MouseEvent<HTMLElement>) => void
}

