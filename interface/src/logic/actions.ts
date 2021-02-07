import Event, { EventForm } from '../types/Event'
import Calendar from '../types/Calendar'
import UrbitApi from './api'
import InitialReducer from './reducers/initial'
import UpdateReducer from './reducers/update'
import Store from './store'

export default class Actions {
  store: Store
  api: UrbitApi

  constructor(store: Store, api: UrbitApi) {
    this.store = store
    this.api = api
  }

  getCalendars = async () : Promise<Calendar[]> => {
    const calendars = await this.api.scry<any>('ucal-store', '/calendars')
    this.store.updateStore({ data: { calendars } })
    return calendars
  }

  getEvents = async () : Promise<Event[]> => {
    const events = await this.api.scry<any>('ucal-store', '/events')
    this.store.updateStore({ data: { events } })
    return events
  }

  createEvent = async (event: EventForm) : Promise<void> => {
    for(let key in event) {
      if (event[key] === undefined) {
        delete event[key]
      }
    }
    console.log('CREATING:', event.toExportFormat())
    await this.api.action('ucal-store', 'ucal-action', event.toExportFormat())
    await this.getEvents()
  }

  createCalendar = async (title: string, isPublic = false) : Promise<void> => {
    await this.api.action('ucal-store', 'ucal-action', {
      'create-calendar': {
        title,
        permissions: {
          readers: [],
          writers: [],
          acolytes: [],
          public: isPublic
        }
      }
    })
  }
}
