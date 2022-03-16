import airlock from "~/logic/api"
// import useCalendarState from '~/logic/state/calendar';

export async function bootstrapApi(reset = false) {
  if (reset) {
    airlock.reset()

    const isResourceView = window.location.href.match(
      /\/resource\/[a-z]*?\/ship\//
    )
    if (isResourceView) {
      return
    }
  }

  airlock.onError = async (err) => {
    airlock.reset()
    console.log("AIRLOCK ERROR", err)
    await bootstrapApi()
  }

  // airlock.onRetry = () => {
  //   useLocalState.setState({ subscription: 'reconnecting' });
  // };

  // airlock.onOpen = () => {
  //   useLocalState.setState({ subscription: 'connected' });
  // };

  // const promises = [
  //   useCalendarState
  // ].map(state => state.getState().initialize(airlock));
  // await Promise.all(promises);
}

window.bootstrapApi = bootstrapApi
