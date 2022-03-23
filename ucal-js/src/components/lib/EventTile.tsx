import React from "react"
import moment from "moment"
import { useTheme } from "styled-components"
import { Text, Box, Col } from "@tlon/indigo-react"

import Event from "../../types/Event"
import { HOUR_HEIGHT } from "../../lib/dates"

interface EventProps {
  weeklyView: boolean
  event: Event
  events?: Event[]
  goToEvent: (event: Event) => (event: React.MouseEvent<HTMLElement>) => void
  mobile?: boolean
  allDay?: boolean
}

const EventTile: React.FC<EventProps> = ({
  weeklyView,
  event,
  goToEvent,
  allDay = false,
  mobile = false,
}) => {
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
  const isLight = black.split(",").includes("255")

  return (
    <Box
      className="event-tile"
      style={{
        backgroundColor: isLight ? "rgba(255,255,255,0.2)" : "rgba(0,0,0,0.2)",
      }}
      height={allDay ? undefined : `${duration * HOUR_HEIGHT}px`}
      width={allDay ? "auto" : "80%"}
      top={allDay ? "0" : `${topDistance * HOUR_HEIGHT + extraMargin}px`}
      left={allDay ? undefined : "10%"}
      position={allDay ? "relative" : "absolute"}
      onClick={goToEvent(event)}
      margin={allDay ? "auto 0px auto 16px" : undefined}
    >
      <Col alignItems={mobile ? "center" : "left"} p="4px 8px">
        <Text>{event.title}</Text>
        {event.invite && <Text fontSize="12px">RSVP: {event.getRsvp()}</Text>}
      </Col>
    </Box>
  )
}

export default EventTile
