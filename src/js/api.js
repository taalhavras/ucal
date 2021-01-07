import _ from 'lodash';

class UrbitApi {
  setAuthTokens(authTokens) {
    this.authTokens = authTokens;
    this.bindPaths = [];
  }

  bind(path, method, ship = this.authTokens.ship, appl = "ucal-store", success, fail) {
    this.bindPaths = _.uniq([...this.bindPaths, path]);

    window.subscriptionId = window.urb.subscribe(ship, appl, path,
      (err) => {
        fail(err);
      },
      (event) => {
        success({
          data: event,
          from: {
            ship,
            path
          }
        });
      },
      (err) => {
        fail(err);
      });
  }

  create_event(calendar_code, title, start, end)
  {
      const obj = {
          'create-event': {
              'calendar-code': calendar_code,
              'title': title,
              'when': { start, end },
              'organizer': 'finled',
              'era': null,
              'tzid': 'utc'
          }
      };
      console.log('create_event', obj);
      this.ucal(obj);
  }

  ucal(data) {
    return this.action("ucal-store", "json", data);
  }

  action(appl, mark, data) {
    return new Promise((resolve, reject) => {
      window.urb.poke(ship, appl, mark, data,
        (json) => {
            console.log('wtf', json);
          resolve(json);
        },
        (err) => {
            console.log('wtf1', err);
          reject(err);
        });
    });
  }
}
export let api = new UrbitApi();
window.api = api;
