export interface Coords {
  lat: number
  lon: number
}

export class Location {
  address: string
  coords?: Coords

  constructor (data: { address: string, coords?: Coords }) {
    this.address = data.address
    this.coords = data.coords
  }
}

export class EventDetail {
  title: string
  desc: string
  location?: Location

  constructor (data: { title: string, desc: string, loc: any }) {
    this.title = data.title
    this.desc = data.desc
    this.location = data.loc ? new Location(data.loc) : undefined
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
  calendar_code: string
  detail: EventDetail
  when: Date
  invites: EventInvite[] = []
  rsvp: Rsvp = Rsvp.yes

  constructor(calendar_code: string, when: Date) {
    this.calendar_code = calendar_code
    this.detail = new EventDetail({ title: '', desc: '', loc: undefined })
    this.when = when
  }

  toExportFormat = () => ({
      'calendar-id': this.calendar_code,
      'title': this.detail.title,
      'desc': this.detail.desc,
      'location': '', // TODO: export location here
  })
}

export default class Event {
  id: string
  calendar_code: string
  about: EventAbout
  detail: EventDetail
  when: Date
  invites: EventInvite[]
  rsvp: Rsvp
  // tzid=tape    -- what is this?

  constructor(data: any) {
    this.id = data.id
    this.calendar_code = data.calendar_code
    this.about = data.about
    this.detail = data.detail
    this.when = data.when
    this.invites = (data.invites || []).map((invite) => new EventInvite(invite))
    this.rsvp = data.rsvp || Rsvp.yes
  }
}
