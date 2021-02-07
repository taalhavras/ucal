import moment from 'moment'
import { EventViewState } from '../views/EventView'

export interface Coords {
  lat: number
  lon: number
}

export class EventLoc {
  address: string
  geo?: Coords // optional when creating event

  constructor (data: { address: string, geo?: Coords }) {
    this.address = data.address
    this.geo = data.geo
  }
}

export enum RepeatInterval {
  doesNotRepeat = 'Does not repeat',
  daily = 'Daily',
  weekly = 'Weekly',
  monthly = 'Monthly',
  yearly = 'Yearly',
}

export enum Weekday {
  mon = 'mon',
  tue = 'tue',
  wed = 'wed',
  thu = 'thu',
  fri = 'fri',
  sat = 'sat',
  sun = 'sun',
}

export const WEEKDAYS = [ Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri, Weekday.sat, Weekday.sun ]

export class Era {
  type: {
    until?: Date
    instances?: number
    infinite?: boolean
  }
  interval: number
  rrule: {
      daily?: boolean
      weekly?: Weekday[]
      monthly?: {
        on?: number
        weekday?: Weekday[]
      }
      yearly?: boolean
  }

  constructor(data?: any) {
    this.type = data?.type
    this.interval = data?.interval
    this.rrule = data?.rrule
  }

  fromRepeatInterval = (repeatInterval: RepeatInterval): Era => {
    // if doesNotRepeat, then shouldn't do anything
    this.type = {
      infinite: true
    }
    this.interval = 1

    switch (repeatInterval) {
      case RepeatInterval.daily:
        this.rrule = { daily: true }
        break
      case RepeatInterval.weekly:
        this.rrule = { weekly: WEEKDAYS }
        break
      case RepeatInterval.monthly:
        this.rrule = { monthly: { on: new Date().getDate() } }
        break
      case RepeatInterval.yearly:
        this.rrule = { yearly: true }
        break
    }

    return this
  }

  // {
  //   'create-event': {
  //     'calendar-code': 'njru-musv',
  //     'organizer': '~zod',
  //     'title': 'my-event',
  //     'desc': 'some-description',
  //     'tzid': 'utc',
  //     'location': {
  //       'address': "14 Manning Ave, Medford, MA 02155"
  //     },
  //     'when': {
  //       'period': {
  //         'start': new Date().getTime(),
  //         'end': new Date().getTime() + 50000
  //       }
  //     },
  //     'era': {
  //       'type': {
  //         'until': new Date().getTime() + 31536000000,
  //       },
  //       'interval': 1,
  //     'rrule': {
  //         'daily': ,
  //         'monthly': {
  //           'on': *number*,
  //           'weekday': []
  //         },
  //         'yearly': null
  //        'weekly': ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
  //     }
  //   }
  // }
}

export class Period {
  period: {
    start: Date, // in milliseconds since epoch
    end: Date // in milliseconds since epoch
  }

  constructor(data?: { start: Date, end: Date }) {
    this.period = {
      start: data?.start ? new Date(data.start) : new Date(),
      end: data?.end ? new Date(data.end) : new Date(),
    }
  }

  setStart = (start: Date) : Period => {
    this.period = { start, end: this.period.end }
    return this
  }

  setEnd = (end: Date) : Period => {
    this.period = { end, start: this.period.start }
    return this
  }
}

export class EventDetail {
  title: string
  desc: string
  location?: EventLoc

  constructor (data: { title: string, desc: string, loc: any }) {
    this.title = data.title
    this.desc = data.desc
    this.location = data.loc ? new EventLoc(data.loc) : undefined
  }
}

export interface EventAbout {
  organizer: string
  created: Date
  modified: Date
}

export class EventInvite {
  note: string
  optional: boolean
  rsvp: Rsvp
  sentAt: Date

  constructor (data: any) {
    this.note = data.note
    this.optional = data.optional
    this.rsvp = data.rsvp
    this.sentAt = new Date(data.sentAt)
  }
}

export enum Rsvp {
  yes = 'yes',
  no = 'no',
  maybe = 'maybe',
}

export class EventForm {
  calendarCode: string | undefined
  eventCode: string | undefined
  organizer: string
  title: string
  desc: string | undefined
  tzid = 'utc'
  location: EventLoc
  start: Date
  end: Date
  era?: Era
  startTime: string
  endTime: string
  allDay: boolean

  constructor(data: EventViewState) {
    this.calendarCode = data.calendarCode
    this.eventCode = data.eventCode
    this.organizer = `~${data.organizer}`
    this.title = data.title
    this.desc = data.desc
    this.location = data.location
    this.start = data.start
    this.end = data.end
    if (data.repeatInterval !== RepeatInterval.doesNotRepeat) {
      this.era = new Era().fromRepeatInterval(data.repeatInterval)
    }
    this.allDay = data.allDay
    this.startTime = data.startTime
    this.endTime = data.endTime
  }

  getMilliseconds = (date: Date, time: string) : number => {
    const [hours, minutes] = time.split(':')
    return moment(date).set('minutes', Number(minutes)).set('hours', Number(hours)).toDate().getTime()
  }

  getPeriod = () : { start: number, end: number } => {
    if (this.allDay) {
      return {
        start: moment(this.start).startOf('day').toDate().getTime(),
        end: moment(this.end).endOf('day').toDate().getTime(),
      }
    }

    return {
      start: this.getMilliseconds(this.start, this.startTime),
      end: this.getMilliseconds(this.end, this.endTime),
    }
  }

  toExportFormat = () => ({
    'create-event': {
      'calendar-code': this.calendarCode,
      'event-code': this.eventCode,
      organizer: this.organizer,
      title: this.title,
      desc: this.desc,
      tzid: this.tzid,
      location: this.location,
      when: { period: this.getPeriod() },
      era: this.era
    }
  })
}

export default class Event {
  eventCode: string
  calendarCode: string
  organizer: string
  title: string
  desc: string
  when: Period
  era: Era
  tzid: string
  invites: EventInvite[]
  rsvp: Rsvp
  created: Date
  modified: Date

  constructor({ data, era }) {
    this.eventCode = data['event-code']
    this.calendarCode = data['calendar-code']
    this.organizer = data.organizer
    this.title = data.title
    this.desc = data.desc
    this.when = new Period({ ...data })
    if (era) {
      this.era = new Era(era)
    }
    this.tzid = data.tzid
    this.invites = (data.invites || []).map((invite) => new EventInvite(invite))
    this.rsvp = data.rsvp || Rsvp.yes
    this.created = new Date(data['date-created'])
    this.modified = new Date(data['last-modified'])
  }
}
