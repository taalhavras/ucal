import React from "react"

import { Text, Box, Row } from "@tlon/indigo-react"
import moment from "moment"
import Event from "../../types/Event"
import { HOUR_HEIGHT } from "../../lib/dates"
import { useTheme } from "styled-components"

interface EventProps {
  weeklyView: boolean
  event: Event
  events?: Event[]
  goToEvent: (
    calendarCode: string,
    eventCode: string
  ) => (event: React.MouseEvent<HTMLElement>) => void
}

const EventTile: React.FC<EventProps> = ({ weeklyView, event, goToEvent }) => {
  const start = moment(event.getStart())
  const startOfDay = moment(start).startOf("day")
  const end = moment(event.getEnd())
  const duration = moment.duration(end.diff(start)).asHours()
  const topDistance = moment.duration(start.diff(startOfDay)).asHours()
  const {
    // @ts-expect-error colors does exist, TS is being dumb.
    colors: { black },
  } = useTheme()

  const extraMargin = weeklyView ? HOUR_HEIGHT / 4 : 0

  return (
    <Box
      className="event-tile"
      style={{
        backgroundColor: black.split(",").includes("255")
          ? "rgba(255,255,255,0.2)"
          : "rgba(0,0,0,0.3)",
      }}
      height={`${duration * HOUR_HEIGHT}px`}
      top={`${topDistance * HOUR_HEIGHT + extraMargin}px`}
      onClick={goToEvent(event.calendarCode, event.eventCode)}
    >
      <Row>
        <Text verticalAlign="middle" padding="4px 8px">
          {event.title}
        </Text>
      </Row>
    </Box>
  )
}

export default EventTile
