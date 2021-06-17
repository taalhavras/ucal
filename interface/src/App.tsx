import React, { useEffect, useState } from "react"
import { BrowserRouter, Route } from "react-router-dom"
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

  return (
    <BrowserRouter>
      <ThemeProvider theme={dark ? darkTheme : lightTheme}>
        <CalendarAndEventProvider>
          <UserLocationProvider>
            <Box
              display="flex"
              flexDirection="column"
              position="absolute"
              backgroundColor="white"
              height="100%"
              width="100%"
              px={[0, 4]}
              pb={[0, 4]}
            >
              <HeaderBar />
              <Route exact path="/~calendar">
                <CalendarWrapper />
              </Route>
              <Route exact path="/~calendar/create">
                <CalendarView />
              </Route>
              <Route exact path="/~calendar/calendar/edit/:calendar">
                <CalendarView />
              </Route>
              <Route exact path="/~calendar/:timeframe/:displayDay">
                <CalendarWrapper />
              </Route>
              <Route exact path="/~calendar/event">
                <EventView />
              </Route>
              <Route exact path="/~calendar/event/:calendar/:event">
                <EventView />
              </Route>
            </Box>
          </UserLocationProvider>
        </CalendarAndEventProvider>
      </ThemeProvider>
    </BrowserRouter>
  )
}
