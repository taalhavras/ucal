import Calendar from '../types/Calendar'
import InitialReducer from './reducers/initial'
import UpdateReducer from './reducers/update'

export interface StoreState {
  calendars: Calendar[]
  events: Event[]
  userLocation: string
}

export default class Store {
  state: StoreState
  setState: any
  initialReducer: InitialReducer
  updateReducer: UpdateReducer
  /*
  The store holds all state for the front-end. We initialise a subscription to the back-end through
  subscription.js and then let the store class handle all incoming diffs, including the initial one
  we get from subscribing to the back-end.

  It's important that state be mutated and set in one place, so pipe changes through the updateStore method.
  */
    constructor() {
        this.state = {
          calendars: [],
          events: [],
          userLocation: ''
        }

        this.initialReducer = new InitialReducer()
        this.updateReducer = new UpdateReducer()
    }

    setStateHandler(setState) {
      this.setState = setState
    }

    updateStore(data) {
      const json = data.data

      Object.keys(json).forEach((key: string) => {
        this.updateReducer.reduce(key, json, this.state)
      })

      console.log('NEW STATE:', this.state)

      this.setState(this.state)
    }
}

export const store = new Store()
