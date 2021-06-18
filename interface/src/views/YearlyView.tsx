import React, { useState } from "react"
import { Text, Box, Button } from "@tlon/indigo-react"
import moment from "moment"
import Calendar, { Timeframe, ViewProps } from "../types/Calendar"
import MonthTile from "../components/lib/MonthTile"
import { scrollToSelectedDay } from "../lib/position"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"

const YearlyView: React.FC<ViewProps> = ({
  selectDay,
  selectedDay,
  goToEvent,
  displayDay,
  createEvent,
}) => {
  const [showDaySummary, setShowDaySummary] = useState<Date>()
  const { calendars } = useCalendarsAndEvents()
  const selectDayHandler =
    (day: Date) =>
    (e: React.MouseEvent<HTMLElement>): void => {
      e.preventDefault()
      e.stopPropagation()

      if (!showDaySummary && selectedDay.getTime() !== day.getTime()) {
        selectDay(day)(e)
      }

      if (day.getTime() === showDaySummary?.getTime()) {
        setShowDaySummary(undefined)
      } else {
        setShowDaySummary(day)
      }
    }

  const hideDaySummary = () => {
    setShowDaySummary(undefined)
  }

  const events = Calendar.getRelevantEvents(calendars, selectedDay).map((e) => (
    <Text
      className="yearly-view-event"
      onClick={goToEvent(e.calendarCode, e.eventCode)}
      key={`${e.calendarCode}-${e.eventCode}`}
    >
      {moment(e.getStart()).format("hh:mm")} - {e.title}
    </Text>
  ))

  return (
    <Box
      display="flex"
      flexDirection="column"
      width="100%"
      height="calc(100vh - 117px)"
      overflow="scroll"
      ref={scrollToSelectedDay(Timeframe.year, selectedDay)}
    >
      <Box
        display="flex"
        flexDirection="row"
        flexWrap="wrap"
        justifyContent="space-around"
        onClick={hideDaySummary}
      >
        {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((month) => (
          <Box margin="20px 20px" key={`year-view-${month}`}>
            <MonthTile
              year={selectedDay.getFullYear()}
              month={month}
              selectDay={selectDayHandler}
              selectedDay={selectedDay}
              displayDay={displayDay}
            />
          </Box>
        ))}
      </Box>
      {!!showDaySummary && (
        <Box id="yearly-view-modal" className="modal" onClick={hideDaySummary}>
          <Box className="content">
            <Text textAlign="center" fontSize={1}>
              {moment(selectedDay).format("ddd, MMMM D - YYYY")}
            </Text>
            {events.length > 0 && (
              <Box marginTop="16px" display="flex" flexDirection="column">
                {events}
              </Box>
            )}
            <Button
              onClick={selectDayHandler(showDaySummary)}
              marginTop="16px"
              width="160px"
            >
              <Text>See all events</Text>
            </Button>
            <Button
              onClick={createEvent(selectedDay)}
              marginTop="16px"
              width="160px"
            >
              <Text>Create new event</Text>
            </Button>
          </Box>
        </Box>
      )}
    </Box>
  )
}

export default YearlyView
