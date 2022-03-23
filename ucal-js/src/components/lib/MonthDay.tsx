import React from "react"
import moment from "moment"

import { Box, Text } from "@tlon/indigo-react"
import DateCircle from "./DateCircle"
import Event from "../../types/Event"

interface Props {
  weekIndex: number
  dayIndex: number
  day: Date
  month: number
  events: Event[]
  goToEvent: (event: Event) => (event: React.MouseEvent<HTMLElement>) => void
  selectDay: (day: Date) => (event: React.MouseEvent<HTMLElement>) => void
}

const MonthDay: React.FC<Props> = ({
  weekIndex,
  dayIndex,
  day,
  month,
  events,
  goToEvent,
  selectDay,
}) => {
  const eventsOnDay = events
    .filter((ae) => ae.isOnDay(day))
    .sort((a, b) => a.compareTo(b))
  const moreThanThree = eventsOnDay.length > 3
  let shownEvents = []

  if (moreThanThree) {
    shownEvents = eventsOnDay.slice(0, 2)
  } else {
    shownEvents = eventsOnDay
  }

  return (
    <Box
      width="14.285%"
      height={weekIndex === 0 ? "120px" : "106px"}
      paddingTop="8px"
      borderLeft={dayIndex === 0 ? "1px solid lightgray" : "none"}
      borderRight="1px solid lightgray"
      display="flex"
      flexDirection="column"
      alignItems="center"
    >
      {weekIndex === 0 && (
        <Text opacity="0.5">
          {moment(day).format("ddd").toLocaleUpperCase()}
        </Text>
      )}
      <DateCircle
        selectDay={selectDay}
        day={day}
        month={month}
        shaded={month !== day.getMonth()}
      >
        {day.getDate()}
      </DateCircle>
      <Box width="100%" display="flex" flexDirection="column">
        {shownEvents.map((ae, ind) => (
          <Box
            className="event-title-ellipsis"
            key={`event-${ind}`}
            onClick={goToEvent(ae)}
          >
            <Text>{ae.title}</Text>
          </Box>
        ))}
        {moreThanThree && (
          <Box className="event-title-ellipsis" onClick={selectDay(day)}>
            <Text>And {eventsOnDay.length - 2} more...</Text>
          </Box>
        )}
      </Box>
    </Box>
  )
}

export default MonthDay
