import React, { useEffect, useState } from "react"
import { BrowserRouter, Route, Redirect } from "react-router-dom"
import HeaderBar from "./components/lib/header-bar.js"

import { ThemeProvider } from "styled-components"

import { CalendarAndEventProvider } from "./hooks/useCalendarsAndEvents"
import { UserLocationProvider } from "./hooks/useUserLocation"

import lightTheme from "./components/themes/light"
import darkTheme from "./components/themes/dark"

import { Box } from "@tlon/indigo-react"
import CalendarWrapper from "./views/CalendarWrapper"
import CalendarView from "./views/CalendarView"
import EventView from "./views/EventView"
import ImportView from "./views/ImportView"
import SyncView from "./views/SyncView"

export const App: React.FC = () => {
  const [dark, setDark] = useState(false)
  let themeWatcher: any

  const updateTheme = (updateTheme): void => {
    setDark(updateTheme)
  }

  useEffect(() => {
    themeWatcher = window.matchMedia("(prefers-color-scheme: dark)")
    setDark(themeWatcher.matches)
    themeWatcher.addListener(updateTheme)
  }, [])

  const urlParams = new URLSearchParams(window.location.search)
  const isEmbedded = urlParams.get("embedded") === "true"

  return (
    <BrowserRouter basename="/apps/calendar">
      <ThemeProvider theme={dark ? darkTheme : lightTheme}>
        <CalendarAndEventProvider>
          <UserLocationProvider>
            <Box
              display="flex"
              flexDirection="column"
              position="absolute"
              backgroundColor="white"
              width="100%"
              px={[0, 4]}
            >
              {!isEmbedded && <HeaderBar />}
              <Route exact path="/">
                <CalendarWrapper />
              </Route>
              <Route exact path="/create">
                <CalendarView />
              </Route>
              <Route exact path="/calendar/edit/:calendar">
                <CalendarView />
              </Route>
              <Route exact path="/:timeframe/:displayDay">
                <CalendarWrapper />
              </Route>
              <Route exact path="/event">
                <EventView />
              </Route>
              <Route exact path="/event/:calendar/:event">
                <EventView />
              </Route>
              <Route exact path="/~calendar/import">
                <ImportView />
              </Route>
              <Route exact path="/~calendar/sync">
                <SyncView />
              </Route>
            </Box>
          </UserLocationProvider>
        </CalendarAndEventProvider>
      </ThemeProvider>
    </BrowserRouter>
  )
}
