import _ from 'lodash'
import Calendar from '../../types/Calendar'
import Event from '../../types/Event'

export default class UpdateReducer {
  // Specify the state property that needs to be updated
  reduce(property: string, json: any, state: any) {
    let data = _.get(json, property, false)
    if (data) {
      this.reduceState(property, data, state)
    }
  }

  // There's a custom handler at the end for specific use cases. In this case, whenever events are updated, 
  reduceState(property: string, value: any, state: any) {
    if (property && value) {

      switch (property) {
        case 'events':
          const events = value.filter((re) => !!re).map((e) => new Event(e))
          state.events = events
          state.calendars = Calendar.generateCalendars(state.calendars, events)
          break;
        case 'calendars':
          const calendars = value.filter((rc) => !!rc).map((c) => new Calendar(c))
          state.calendars = Calendar.generateCalendars(calendars, state.events)
          break;
        case 'location':
          state.userLocation = value
          break;
        default:
          state[property] = value
      }
    }
  }
}
