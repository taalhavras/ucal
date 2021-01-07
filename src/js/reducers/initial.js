import _ from 'lodash';


export class InitialReducer {
  /* if we get a diff from the app that looks like this:

  { initial: {}}

  it will set the state to look like the contents of "initial"

  */
    reduce(json, state) {
        let cals = _.get(json, 'allCalendars', false);
        if (cals) {
            state.allCalendars = cals;
        }
        let events = _.get(json, 'allEvents', false);
        if (events) {
            state.allEvents = events;
        }
    }
}
