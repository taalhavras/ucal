import React from "react"

import { Text, Box } from "@tlon/indigo-react"
import moment from "moment"
import Calendar, { Timeframe, ViewProps } from "../types/Calendar"
import { getHours, HOUR_HEIGHT } from "../lib/dates"
import HoursBar from "../components/lib/HoursBar"
import EventTile from "../components/lib/EventTile"
import { scrollToSelectedDay } from "../lib/position"
import { useUserLocation } from "../hooks/useUserLocation"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"

const DailyView: React.FC<ViewProps> = ({
  selectedDay,
  displayDay,
  goToEvent,
  mobile,
}) => {
  const { calendars } = useCalendarsAndEvents()
  const { userLocation } = useUserLocation()
  const hours = getHours()
  const selectedMoment = moment(selectedDay)

  const events = Calendar.getRelevantEvents(calendars, selectedDay).map(
    (e, _ind, events) => (
      <EventTile
        goToEvent={goToEvent}
        weeklyView={false}
        event={e}
        events={events}
        key={`${e.calendarCode}${e.eventCode}`}
      />
    )
  )

  return (
    <Box
      display="flex"
      flexDirection="column"
      width="100%"
      margin="16px 0px 0px 0px"
    >
      <Box
        marginLeft="14%"
        display="flex"
        flexDirection="column"
        width="40px"
        alignItems="center"
      >
        <Text>{selectedMoment.format("ddd").toLocaleUpperCase()}</Text>
        <Text fontSize="2">
          {selectedMoment.format("D").toLocaleUpperCase()}
        </Text>
      </Box>
      <Box
        width="100%"
        height="calc(100vh - 212px)"
        overflowY="scroll"
        ref={scrollToSelectedDay(Timeframe.day, selectedDay)}
      >
        <Box display="flex" flexDirection="row" width="100%">
          <HoursBar
            displayDay={displayDay}
            userLocation={userLocation}
            mobile={mobile}
          />
          <Box
            display="flex"
            flexDirection="column"
            width="87.5%"
            alignItems="flex-end"
          >
            <Box
              width="100%"
              height="24px"
              borderLeft="1px solid lightgray"
              borderBottom="1px solid lightgray"
              display="flex"
              flexDirection="column"
              alignItems="center"
            >
              {/* this is for all-day events */}
            </Box>
            <Box width="100%" position="relative">
              {hours.map((hour) => (
                <Box
                  width="100%"
                  height={`${HOUR_HEIGHT}px`}
                  borderLeft="1px solid lightgray"
                  borderBottom="1px solid lightgray"
                  display="flex"
                  flexDirection="column"
                  alignItems="center"
                  key={`hour-blocks-${hour}`}
                ></Box>
              ))}
              {events}
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  )
}

export default DailyView
