import _ from 'lodash'
import Calendar from '../../types/Calendar'

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
      state[property] = value

      switch (property) {
        case 'events':
          state.calendars = Calendar.generateCalendars(state.calendars, value)
          break;
        case 'calendars':
          state.calendars = Calendar.generateCalendars(value, state.events)
          break;
      }
    }
  }
}
