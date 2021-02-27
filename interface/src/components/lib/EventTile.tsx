import React, { Component } from 'react'

import { Text, Box, Row } from '@tlon/indigo-react'
import moment from 'moment'
import Event from '../../types/Event'
import { HOUR_HEIGHT } from '../../lib/dates'

interface EventProps {
  weeklyView: boolean
  event: Event
  events: Event[]
  goToEvent: (calendarCode: string, eventCode: string) => (event: React.MouseEvent<HTMLElement>) => void
}

export default class EventTile extends Component<EventProps> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { event, goToEvent, weeklyView} } = this
    const start = moment(event.getStart())
    const startOfDay = moment(start).startOf('day')
    const end = moment(event.getEnd())
    const duration = moment.duration(end.diff(start)).asHours()
    const topDistance = moment.duration(start.diff(startOfDay)).asHours()

    const extraMargin = weeklyView ? HOUR_HEIGHT / 4 : 0

    return (
      <Box className="event-tile"
          height={`${duration * HOUR_HEIGHT}px`}
          top={`${topDistance * HOUR_HEIGHT + extraMargin}px`}
          onClick={goToEvent(event.calendarCode, event.eventCode)}>
        <Row>
          <Text verticalAlign='middle' padding="4px 8px">
            {event.title}
          </Text>
        </Row>
      </Box>
    )
  }
}
