import _, { create } from 'lodash'
import { warnError } from '../lib/format'

export default class UrbitApi {
  authTokens: any
  bindPaths: string[] = []
  subscriptionId: any

  constructor() {
    this.authTokens = {
      ship: (window as any).ship
    }
  }

  setAuthTokens(authTokens: any) {
    this.authTokens = authTokens
  }

  bind(path, method, ship = this.authTokens.ship, appl = "ucal-store", success, fail) {
    this.bindPaths = _.uniq([...this.bindPaths, path])

    this.subscriptionId = (window as any).urb.subscribe(ship, appl, path,
      (err) => {
        fail(err)
      },
      (event) => {
        success({
          data: event,
          from: {
            ship,
            path
          }
        })
      },
      (err) => {
        fail(err)
      })
  }

  action = (appl, mark, data) : Promise<void> => {
    console.log('ACTION', this.authTokens.ship, appl, mark, data)
    return new Promise((resolve, reject) => {
      (window as any).urb.poke(this.authTokens.ship, appl, mark, data,
        (json) => {
          console.log('ACTION SUCCESS', appl, json)
          resolve(json)
        },
        (err) => {
          console.log('ACTION FAILURE', appl, err)
          reject(err)
        })
    })
  }

  scry<T>(app: string, path: string): Promise<T|void> {
    console.log('SCRY', app, path)
    return fetch(`/~/scry/${app}/~${this.authTokens.ship}${path}.json`).then((r) => {
      if (r.status === 404) {
        throw new Error('Not found')
      } else if (r.status > 399) {
        throw new Error('Scry failed')
      }
      return r.json() as Promise<T>
    }).catch()
  }
}
