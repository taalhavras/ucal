import { arraysMatch } from '../lib/arrays'
import { CalendarViewState } from '../views/CalendarView'
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
  public: boolean
}

export const permissionsMatch = (current: Permissions, changed: Permissions) => {
  return current.public === changed.public
    && arraysMatch(current.readers, changed.readers)
    && arraysMatch(current.writers, changed.writers)
    && arraysMatch(current.acolytes, changed.acolytes)
}

export const DEFAULT_PERMISSIONS : Permissions = {
  readers: [],
  writers: [],
  acolytes: [],
  public: false,
}

export type CalendarPermission = 'reader' | 'writer' | 'acolyte' | null

export interface CalendarPermissionsChange {
  who: string,
  role?: CalendarPermission,
}

export interface CalendarCreationData extends Permissions {
  title: string
  calendar?: Calendar
  changes: CalendarPermissionsChange[]
  readers: string[]
  writers: string[]
  acolytes: string[]
  public: boolean
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
    if (data instanceof Calendar) {
      return Object.assign(this, data)
    }
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

  toggle = (calendar: Calendar) => {
    if (calendar.calendarCode === this.calendarCode) {
      this.active = !this.active
    }
    return this
  }

  toFormFormat = () : CalendarViewState => ({
    title: this.title,
    ...this.permissions,
    calendar: this,
    changes: [],
    reader: '',
    writer: '',
    acolyte: '',
  })

  isUnchanged = (state: CalendarViewState) => {
    const titleUnchanged = state.title === this.title
    const permissionsUnchanged = permissionsMatch(this.permissions, { ...state })

    return titleUnchanged && permissionsUnchanged
  }

  static generateCalendars = (calendars: Calendar[], events: Event[]) : Calendar[] => {
    const all = new Map<string, Calendar | undefined>()

    calendars.forEach((calendar) => all.set(calendar.calendarCode, calendar.clearEvents()))
    events.forEach((event) => {
      const updatedCalendar = all.get(event.calendarCode)
      if (updatedCalendar?.active && !updatedCalendar.events.find((e) => e.eventCode === event.eventCode)) {
        updatedCalendar?.events.push(event)
      }
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

  static getRelevantEvents = (calendars: Calendar[], date: Date) => calendars.filter((c) => c.active)
    .reduce((acc: Event[], cur: Calendar) => acc.concat(cur.events), [])
    .filter((e) => e.isOnDay(date))
    .sort((a, b) => a.compareTo(b))

  static toExportFormat = (data: CalendarViewState, update: boolean) => {
    const formattedData = {
      title: data.title,
      permissions: {
        readers: data.readers,
        writers: data.writers,
        acolytes: data.acolytes,
        public: data.public,
      }
    }

    return update ? {
      'update-calendar': formattedData
    } : {
      'create-calendar': formattedData
    }
  }
}

export interface ViewProps {
  calendars: Calendar[]
  displayDay: Date
  selectedDay: Date
  selectDay: (day: Date) => (event: React.MouseEvent<HTMLElement>) => void
  userLocation: string
  goToEvent: (calendarCode: string, eventCode: string) => (event: React.MouseEvent<HTMLElement>) => void
  createEvent: (day?: Date) => () => void
}

