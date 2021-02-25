import { Rule } from '@tlon/indigo-react'
import moment from 'moment'
import { isSameDay, sameMonthDay, getHoursMinutes } from '../lib/dates'
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

  toExportFormat = () => {
    if (!this.geo) {
      return { address: this.address }
    }

    return {
      address: this.address,
      geo: this.geo
    }
  }

  compareTo = (other: EventLoc) : number => {
    if (this.address === other.address) {
      return 0
    } else if (this.address > other.address) {
      return 1
    } else {
      return -1
    }
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
  sun = 'sun',
  mon = 'mon',
  tue = 'tue',
  wed = 'wed',
  thu = 'thu',
  fri = 'fri',
  sat = 'sat',
}

export const WEEKDAYS = [ Weekday.sun, Weekday.mon, Weekday.tue, Weekday.wed, Weekday.thu, Weekday.fri, Weekday.sat ]

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

  isOnDay = (day: Date, start: Date, end: Date) : boolean => {
    const { type, interval, rrule } = this
    const moDay = moment(day)

    const untilMatch = !!type.until && moDay.isSameOrBefore(type.until)
    const instancesMatch = !!type.instances && false // How to calculate the number of instances?
    const typeMatch = (type.infinite !== undefined) || untilMatch || instancesMatch

    const weeklyMatch = !!rrule.weekly?.includes(moDay.format('ddd').toString().toLowerCase() as Weekday)
    const monthlyMatch = !!rrule.monthly && (day.getDate() === start.getDate() || day.getDate() === end.getDate()) // TODO: handle day-of-week case
    const yearlyMatch = !!rrule.yearly && (sameMonthDay(day, start) || sameMonthDay(day, end))

    const repeatMatch = rrule.daily !== undefined || weeklyMatch || monthlyMatch || yearlyMatch

    return typeMatch && repeatMatch
  }

  getRepeatInterval = () : RepeatInterval => {
    if (this.rrule.daily !== undefined) {
      return RepeatInterval.daily
    } else if (this.rrule.weekly) {
      return RepeatInterval.weekly
    } else if (this.rrule.monthly) {
      return RepeatInterval.monthly
    } else {
      return RepeatInterval.yearly
    }
  }

  getWeekdays = () : Weekday[] => this.rrule?.weekly || []

  fromRepeatInterval = (repeatInterval: RepeatInterval, weekdays: Weekday[]): Era => {
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
        this.rrule = { weekly: weekdays }
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

  matchesInterval = (repeatInterval: RepeatInterval) : boolean => {
    switch (repeatInterval) {
      case RepeatInterval.daily:
        return !this.rrule?.daily
      case RepeatInterval.weekly:
        return !this.rrule?.weekly
      case RepeatInterval.monthly:
        return !this.rrule?.monthly
      case RepeatInterval.yearly:
        return !this.rrule?.yearly
    }

    return false
  }
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

  getStart = () : Date => this.period.start

  getEnd = () : Date => this.period.end

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
      this.era = new Era().fromRepeatInterval(data.repeatInterval, data.weekdays)
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

  isUnchanged = (state: EventViewState) : boolean => {
    return this.title === state.title &&
    this.desc === state.desc &&
    this.location.compareTo(state.location) === 0 &&
    this.start === state.start &&
    this.end === state.end &&
    ( (!this.era && state.repeatInterval === RepeatInterval.doesNotRepeat) || !this.era?.matchesInterval(state.repeatInterval) ) &&
    this.startTime === state.startTime &&
    this.endTime === state.endTime &&
    this.allDay === state.allDay
  }

  toExportFormat = (update: boolean) => {
    const data = {
      'calendar-code': this.calendarCode,
      'event-code': this.eventCode,
      organizer: this.organizer,
      title: this.title,
      desc: this.desc,
      tzid: this.tzid,
      location: this.location.toExportFormat(),
      when: { period: this.getPeriod() },
      era: this.era
    }

    if (update) {
      delete data.organizer
    }

    return update ? { 'update-event': data } : { 'create-event': data }
  }
}

export default class Event {
  eventCode: string
  calendarCode: string
  organizer: string
  title: string
  desc: string
  location: EventLoc
  when: Period
  era?: Era
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
    this.location = new EventLoc(data.location)
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

  getStart = () : Date => this.when.getStart()

  getEnd = () : Date => this.when.getEnd()

  isOnDay = (day: Date) : boolean => {
    const { era, when, getStart, getEnd } = this

    if (isSameDay(getStart(), day) || isSameDay(getEnd(), day)) {
      return true
    }

    return !!era && era.isOnDay(day, getStart(), getEnd())
  }

  toFormFormat = () : EventViewState => {
    return {
      ...this,
      location: new EventLoc({ address: '' }),
      start: this.getStart(),
      repeatInterval: this.era?.getRepeatInterval() || RepeatInterval.doesNotRepeat,
      weekdays: this.era?.getWeekdays(),
      end: this.getEnd(),
      allDay: Math.round(moment(this.getStart()).diff(this.getEnd(), 'hours')) === 24,
      startTime: getHoursMinutes(this.getStart()),
      endTime: getHoursMinutes(this.getEnd()),
      event: this
    }
  }

  isUnchanged = (state: EventViewState) : boolean => {
    return new EventForm(state).isUnchanged(this.toFormFormat())
  }
}
