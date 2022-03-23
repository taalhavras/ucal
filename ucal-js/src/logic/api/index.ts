import Urbit from "@urbit/http-api"
const api = new Urbit("", "", "ucal")
const ship = window.location.href.split("//")[1].split(".")[0]

api.ship = window.ship
// api.verbose = true;
// @ts-ignore TODO window typings
window.api = api

export function scryNoShip<T>(app: string, path: string): Promise<T | void> {
  return fetch(`/~/scry/${app}${path}.json`)
    .then((r) => {
      if (r.status === 404) {
        throw new Error("Not found")
      } else if (r.status > 399) {
        throw new Error("Scry failed")
      }
      return r.json() as Promise<T>
    })
    .catch()
}

export default api
