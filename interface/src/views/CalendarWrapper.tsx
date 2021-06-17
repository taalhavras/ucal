import React, { useState } from "react"
import { capitalize } from "lodash"

import { Text, Box, Button, Checkbox, Row, Icon } from "@tlon/indigo-react"
import moment from "moment"
import Calendar, { NavDirection, Timeframe } from "../types/Calendar"
import WeeklyView from "./WeeklyView"
import DailyView from "./DailyView"
import MonthlyView from "./MonthlyView"
import YearlyView from "./YearlyView"
import Title from "../components/lib/Title"
import MonthTile from "../components/lib/MonthTile"
import {
  match,
  RouteComponentProps,
  withRouter,
  useHistory,
} from "react-router-dom"
import { Location, History } from "history"
import { HOUR_HEIGHT } from "../lib/dates"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"

interface RouterProps {
  timeframe: string
  displayDay: string
}

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
}

export const CalendarWrapper: React.FC<Props> = ({ match }) => {
  const { calendars, getCalendars, deleteCalendar, toggleCalendar } =
    useCalendarsAndEvents()
  const history = useHistory()
  const { timeframe, displayDay } = match.params
  const useTf = (timeframe && (timeframe as Timeframe)) || Timeframe.month
  const useDd = (displayDay && moment(displayDay).toDate()) || new Date()
  const [timeframeState, setTimeframeState] = useState(useTf)
  const [displayDayState, setDisplayDayState] = useState(useDd)
  const [selectedDayState, setSelectedDayState] = useState(useDd)
  const [showCalendarModal, setShowCalendarModal] = useState(false)

  const pushViewRoute = (tf: Timeframe, dd: Date): void =>
    history.push(`/~calendar/${tf}/${moment(dd).format("YYYY-MM-DD")}`)

  const goToToday = (): void => {
    const displayDay = new Date()
    pushViewRoute(timeframeState, displayDayState)
    setDisplayDayState(displayDay)
    setSelectedDayState(displayDay)
  }

  const selectTimeframe = (e: React.ChangeEvent<HTMLSelectElement>): void => {
    e.stopPropagation()
    e.preventDefault()
    const timeframe = e.target.value as Timeframe
    pushViewRoute(timeframe, selectedDayState)
    setTimeframeState(timeframe)
  }

  const selectDay = (selectedDay: Date, isSidebar?: boolean) => (): void => {
    let timeframe = Timeframe.day
    if (isSidebar) {
      timeframe = timeframeState
    } else if (
      timeframeState === Timeframe.year &&
      selectedDayState.getTime() !== selectedDay.getTime()
    ) {
      timeframe = Timeframe.year
    }
    pushViewRoute(timeframe, selectedDay)
    setSelectedDayState(selectedDay)
    setDisplayDayState(selectedDay)
  }

  const changeRange = (direction: NavDirection) => () => {
    const newDisplay = moment(displayDayState)
      [direction](1, timeframeState)
      .toDate()
    const newSelected = newDisplay

    pushViewRoute(timeframeState, newSelected)
    setDisplayDayState(newDisplay)
    setSelectedDayState(newSelected)
  }

  const createEvent = (day?: Date) => () =>
    history.push(`/~calendar/event${day ? `?date=${day?.getTime()}` : ""}`)

  const goToEvent = (calendarCode: string, eventCode: string) => (): void => {
    history.push(`/~calendar/event/${calendarCode}/${eventCode}`)
  }

  const hideCalendarModal = (e?: React.MouseEvent<HTMLElement>) => {
    e?.preventDefault()
    e?.stopPropagation()
    setShowCalendarModal(false)
  }

  const addCalendar = () => {
    setShowCalendarModal(true)
  }

  const createCalendar = (calendarCode?: string) => () => {
    hideCalendarModal()
    history.push(
      `/~calendar/${calendarCode ? `calendar/edit/${calendarCode}` : "create"}`
    )
  }

  const deleteCalendarHandler = (calendar: Calendar) => {
    deleteCalendar(calendar)
    getCalendars()
  }

  let layout = (
    <WeeklyView
      displayDay={displayDayState}
      selectedDay={selectedDayState}
      goToEvent={goToEvent}
      createEvent={createEvent}
    />
  )
  switch (timeframe) {
    case Timeframe.day:
      layout = (
        <DailyView
          displayDay={displayDayState}
          selectedDay={selectedDayState}
          goToEvent={goToEvent}
          createEvent={createEvent}
        />
      )
      break
    case Timeframe.month:
      layout = (
        <MonthlyView
          selectDay={selectDay}
          displayDay={displayDayState}
          selectedDay={selectedDayState}
          goToEvent={goToEvent}
          createEvent={createEvent}
        />
      )
      break
    case Timeframe.year:
      layout = (
        <YearlyView
          selectDay={selectDay}
          displayDay={displayDayState}
          selectedDay={selectedDayState}
          goToEvent={goToEvent}
          createEvent={createEvent}
        />
      )
      break
  }

  return (
    <Box
      height="100%"
      p="4"
      display="flex"
      flexDirection="column"
      borderWidth={["none", "1px"]}
      borderStyle="solid"
      borderColor="washedGray"
    >
      <Box
        width="100%"
        display="flex"
        flexDirection="row"
        justifyContent="space-between"
        borderBottom="1px solid lightGray"
        paddingBottom="12px"
      >
        <Box height="100%" display="flex" flexDirection="row">
          <Text
            pt="4"
            border="2px solid black"
            borderRadius="4px"
            height="12px"
            padding="2px 3px"
            margin="5px 8px 0px 0px"
          >
            {moment().format("DD")}
          </Text>
          <Text fontSize="1" margin={`6px ${HOUR_HEIGHT}px 0px 0px`}>
            Calendar
          </Text>
          <Button onClick={() => goToToday()}>Today</Button>

          <Box
            height="100%"
            display="flex"
            flexDirection="row"
            margin="0px 24px"
          >
            <Button
              onClick={changeRange(NavDirection.left)}
              fontSize="3"
              border="none"
            >
              &lsaquo;
            </Button>
            <Button
              onClick={changeRange(NavDirection.right)}
              fontSize="3"
              border="none"
            >
              &rsaquo;
            </Button>
          </Box>

          <Title selectedDay={selectedDayState} timeframe={timeframeState} />
        </Box>

        <Box
          height="100%"
          display="flex"
          flexDirection="row"
          padding="0px 8px"
          border="1px solid rgba(0, 0, 0, 0.3)"
          borderRadius="4px"
        >
          <select
            className="timeframe"
            value={timeframe}
            onChange={selectTimeframe}
          >
            {Object.values(Timeframe).map((tf, ind) => (
              <option value={tf} key={`timeframe-${ind}`}>
                {capitalize(tf)}
              </option>
            ))}
          </select>
        </Box>
      </Box>
      <Row width="100%">
        <Box display="flex" flexDirection="column" margin="32px 2% 0px 0px">
          <Button onClick={createEvent()} marginBottom="20px" width="100px">
            <Text fontSize="20px">+</Text>{" "}
            <Text margin="2px 0px 0px 6px" fontSize="14px">
              Create
            </Text>
          </Button>
          <MonthTile
            selectDay={selectDay}
            displayDay={displayDayState}
            sidebar
            showYear
            showNavArrows
            selectedDay={selectedDayState}
          />
          <Text fontSize="1" margin="20px 0px 0px 0px">
            Calendars
          </Text>
          {calendars.map((cal, ind) => (
            <Row className="calendar-selector" key={`cal-${ind}`}>
              <Row>
                <Checkbox
                  selected={cal.active}
                  onClick={() => toggleCalendar(cal)}
                />
                <Text marginLeft="8px">
                  {cal.owner} - {cal.title}
                </Text>
              </Row>
              <Row className="edit-icon">
                <Icon
                  icon="Ellipsis"
                  color="black"
                  onClick={createCalendar(cal.calendarCode)}
                />
                <Icon
                  icon="TrashCan"
                  color="black"
                  onClick={() => deleteCalendarHandler(cal)}
                />
              </Row>
            </Row>
          ))}
          <Button onClick={() => addCalendar()} marginTop="16px" width="120px">
            <Text fontSize="12px">Add Calendar</Text>
          </Button>
        </Box>

        {layout}
      </Row>

      {showCalendarModal && (
        <Box
          onClick={hideCalendarModal}
          id="create-calendar-modal"
          className="modal"
        >
          <Box className="content">
            <Button
              onClick={createCalendar()}
              marginTop="16px"
              maxWidth="200px"
            >
              <Text fontSize="14px">Create Calendar</Text>
            </Button>
          </Box>
        </Box>
      )}
    </Box>
  )
}

export default withRouter(CalendarWrapper)
