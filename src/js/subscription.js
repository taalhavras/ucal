import { api } from './api';
import { store } from './store';

export class Subscription {

  // uncomment the following code to start up a subscription on the '/' path
  //
  // see on-watch in your app's hoon file for behaviour
  //
  start() {
    if (api.authTokens) {
      this.initialize_ucal();
    } else {
      console.error("~~~ ERROR: Must set api.authTokens before operation ~~~");
    }
  }

  initialize_ucal() {
    api.bind('/almanac', 'PUT', api.authTokens.ship, 'ucal-store',
      this.handleEvent.bind(this),
      this.handleError.bind(this));

    fetch('/~/scry/ucal-store/~finled/calendars.json')
      .then((r) => r.json())
      .then((r)=>{
        console.log('calendars', r);
        store.handleEvent({data: {allCalendars: r}});
      });

    fetch('/~/scry/ucal-store/~finled/events.json')
      .then((r) => r.json())
      .then((r)=>{
        console.log('events', r)
        store.handleEvent({data: {allEvents: r}});
      });
  }

  handleEvent(diff) {
    console.log('diff', diff);
    store.handleEvent(diff);
  }

  handleError(err) {
    console.error(err);
    api.bind('/almanac', 'PUT', api.authTokens.ship, 'ucal-store',
      this.handleEvent.bind(this),
      this.handleError.bind(this));
  }
}

export let subscription = new Subscription();
