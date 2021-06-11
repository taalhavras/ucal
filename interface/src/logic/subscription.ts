import Actions from './actions'
import Store from './store'
import UrbitApi from './api'
import { warnError } from '../lib/format'
import { DEFAULT_PERMISSIONS } from '../types/Calendar'

export default class Subscription {
  actions: Actions
  store: Store
  api: UrbitApi

  constructor(store: Store, actions: Actions, api: UrbitApi) {
    this.actions = actions
    this.store = store
    this.api = api

    if (this.api.authTokens) {
      this.initialize()
    } else {
      console.error("~~~ ERROR: Must set api.authTokens before operation ~~~")
    }
  }

  initialize = async () : Promise<void> => {
    // this.api.bind('/almanac', 'PUT', this.api.authTokens.ship, 'ucal-store',
    //   this.handleEvent.bind(this),
    //   this.handleError.bind(this))

    try {
      const calendars = await this.actions.getCalendars()

      if (calendars.length < 1) {
        try {
          await this.actions.saveCalendar({ title: 'default', ...DEFAULT_PERMISSIONS })
          await this.actions.getCalendars()
        } catch (error) {}
      }
      
      await this.actions.getEvents()
      await this.actions.getInvitedEvents()
      await this.actions.getTest()
    } catch (error) {
      warnError('SCRY')(error)

      if (error.toString().includes('Not found')) {
        try {
          await this.actions.saveCalendar({ title: 'default', ...DEFAULT_PERMISSIONS })
          await this.actions.getCalendars()
        } catch (createError) {
          warnError('CREATE CALENDAR')(createError)
        }
      }
    }
  }

  handleEvent = (diff) => {
    this.store.updateStore(diff)
  }

  handleError = (err) => {
    console.error(err)
    this.api.bind('/almanac', 'PUT', this.api.authTokens.ship, 'ucal-store',
      this.handleEvent.bind(this),
      this.handleError.bind(this))
  }
}
