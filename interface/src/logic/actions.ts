import Event, { EventForm } from '../types/Event'
import Calendar from '../types/Calendar'
import UrbitApi from './api'
import InitialReducer from './reducers/initial'
import UpdateReducer from './reducers/update'
import Store from './store'
import { CalendarViewState } from '../views/CalendarView'
import { calendarFormat } from 'moment'

// TODO: break out event types

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

  saveCalendar = async (data : CalendarViewState, update = false) : Promise<void> => {
    console.log('SAVING:', JSON.stringify(Calendar.toExportFormat(data, update)))
    
    if (data.calendar?.title !== data.title) {
      await this.api.action('ucal-store', 'ucal-action', Calendar.toExportFormat(data, update))
    }
    if (data.calendar && data.calendar?.permissions?.public !== data.public) {
      const payload = { 'change-permissions': {'calendar-code': data.calendar.calendarCode } }
      payload['change-permissions'][data.public ? 'make-public' : 'make-private'] = null

      await this.api.action('ucal-store', 'ucal-action', payload)
    }
    
    // Handle permissions changes

    await this.getCalendars()
  }

  deleteCalendar = async (calendar: Calendar) : Promise<boolean> => {
    const confirmed = confirm('Are you sure you want to delete this calendar? This cannot be undone.')

    if (confirmed) {
      await this.api.action('ucal-store', 'ucal-action', {
        'delete-calendar': {
          'calendar-code': calendar.calendarCode,
        }
      })
      await this.getCalendars()
    }
    
    return confirmed
  }

  getEvents = async () : Promise<Event[]> => {
    const events = await this.api.scry<any>('ucal-store', '/events')
    this.store.updateStore({ data: { events } })
    return events
  }

  deleteEvent = async (event: Event) : Promise<void> => {
    await this.api.action('ucal-store', 'ucal-action', {
      'delete-event': {
        'calendar-code': event.calendarCode,
        'event-code': event.eventCode
      }
    })
  }

  saveEvent = async (event: EventForm, update: boolean) : Promise<void> => {
    for(let key in event) {
      if (event[key] === undefined) {
        delete event[key]
      }
    }
    console.log('SAVING:', JSON.stringify(event.toExportFormat(update)))
    await this.api.action('ucal-store', 'ucal-action', event.toExportFormat(update))
    await this.getEvents()
  }

  toggleCalendar = (calendar: Calendar) => () => this.store.updateStore({ data: { calendars: this.store.state.calendars.map((c) => c.toggle(calendar)) } })
}
