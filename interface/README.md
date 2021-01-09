# ucal interface

Created from tlon's [create-landscape-app](https://github.com/urbit/create-landscape-app).

## Installation

0. Ensure your have followed installation instructions for the main repo.

1. On your Urbit ship, if you haven't already, mount your pier to Unix with `|mount %`.

2. Run `npm i --also=dev`.

3. Change the name of .urbitrc-sample to .urbitrc and change line 3 to your ship's path and the port on line 5 to your ship's localhost port.

## Development

Once you're up and running, your application lives in the `src` folder; `src` uses [React](https://reactjs.org) to render itself -- you'll want a basic foothold with it first.

Run `npm run serve` to serve a dev server environment with hot reloading at `localhost:9000`.

## Production

1. Run `npm run build` to bundle the necessary files and copy them to your ship.

2. Run `|commit %home` on your ship.
