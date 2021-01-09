import React, { Component } from 'react'
import { BrowserRouter, Route } from "react-router-dom"
import _ from 'lodash'
import HeaderBar from "./components/lib/header-bar.js"

import { ThemeProvider } from 'styled-components'

import light from './components/themes/light'
import dark from './components/themes/dark'

import { Box } from '@tlon/indigo-react'
import CalendarView from './views/CalendarView'
import Store, { StoreState } from './logic/store'
import EventView from './views/EventView'
import Actions from './logic/actions'
import UrbitApi from './logic/api'
import Subscription from './logic/subscription'

interface Props {}

interface State extends StoreState {
  dark: boolean
}

export class App extends Component<Props, State> {
  themeWatcher: any
  store: Store
  actions: Actions
  api: UrbitApi
  subscription: Subscription

  constructor(props) {
    super(props)

    this.store = new Store()
    this.store.setStateHandler(this.setState.bind(this))
    this.state = { ...this.store.state, dark: false }
    this.api = new UrbitApi()
    this.actions = new Actions(this.store, this.api)

    this.subscription = new Subscription(this.store, this.actions, this.api)
  }

  updateTheme = (updateTheme) : void => {
    this.setState({ dark: updateTheme })
  }

  componentDidMount() {
    this.themeWatcher = window.matchMedia('(prefers-color-scheme: dark)')
    this.setState({ dark: this.themeWatcher.matches })
    this.themeWatcher.addListener(this.updateTheme)
  }

  render() {
    return (
      <BrowserRouter>
        <ThemeProvider theme={this.state.dark ? dark : light}>
        <Box display='flex' flexDirection='column' position='absolute' backgroundColor='white' height='100%' width='100%' px={[0,4]} pb={[0,4]}>
        <HeaderBar/>
        <Route exact path="/~calendar" render={ () => <CalendarView {...this.state} />}/>
        <Route exact path="/~calendar/:timeframe/:displayDay" render={ () => <CalendarView {...this.state} />}/>
        <Route exact path="/~calendar/event" render={ () => <EventView {...this.state} />}/>
        <Route exact path="/~calendar/event/:calendar/:event" render={ () => <EventView {...this.state} {...this.actions} />}/>
        </Box>
        </ThemeProvider>
      </BrowserRouter>
    )
  }
}

