import React, { Component } from 'react'

import { Text, Box, Row, Button } from '@tlon/indigo-react'
import moment from 'moment'
import { ViewProps } from '../types/Calendar'
import { getHours } from '../lib/dates'
import HoursBar from '../components/lib/HoursBar'

interface State {}

class DailyEvent extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { props: { color, referenceTime, event } } = this
    const s = moment(event.start);
    const e = moment(event.end);
    const duration = moment.duration(e.diff(s)).asHours();
    const topDistance = moment.duration(s.diff(referenceTime)).asHours();

    let seeEvent = () =>
    this.props.history.push(`/~calendar/event/${event.calendar_code}/${event.event_code}`)

    return (
      <Box
          height={(duration * 48) + 'px'}
          width='80%'
          backgroundColor={color}
          position='absolute'
          left='50px'
          top={(topDistance * 48) + 'px'}
          onClick={seeEvent}>
        <Row>
          <Text
              paddingLeft='0.3rem'
              paddingTop='0.3rem'
              bold fontSize={1}>
            {event.detail.title}
          </Text>
        </Row>
        <Row>
          <Text paddingLeft='0.3rem' paddingTop='0.3rem'>{event.detail.desc}</Text>
        </Row>
      </Box>
    );
  }
};

export default class DailyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { calendars, selectedDay, selectDay } } = this
    const hours = getHours()
    const selectedMoment = moment(selectedDay)

    console.log(calendars);

    const startDay = moment(selectedMoment);
    const endDay = moment(selectedMoment).add(1, 'day');

    let events = calendars.length > 0 ? calendars[0].events
      .filter((e) => {
        let startTime = moment.utc(e.start);
        return startTime.isAfter(startDay) && startTime.isBefore(endDay);
      })
      .map((e) => (<DailyEvent
        history={this.props.history}
        color='green'
        referenceTime={selectedMoment}
        event={e}
        key={e.event_code}
        />)) : [];

    console.log(events);

    return (
      <Box display='flex' flexDirection='column' width='100%' margin='16px 0px 0px 0px'>
        <Box marginLeft='14%' display='flex' flexDirection='column' width='40px' alignItems='center'>
          <Text>{selectedMoment.format('ddd').toLocaleUpperCase()}</Text>
          <Text fontSize='2'>{selectedMoment.format('D').toLocaleUpperCase()}</Text>
        </Box>
        <Box width='100%' height='calc(100vh - 212px)' overflowY='scroll'>
          <Box display='flex' flexDirection='row' width='100%'>
            <HoursBar {...this.props} />
            <Box display='flex' flexDirection='column' width='87.5%' alignItems='flex-end'>
              <Box width='100%' height='24px' borderLeft='1px solid lightgray' borderBottom='1px solid lightgray' display='flex' flexDirection='column' alignItems='center'>
                {/* this is for all-day events */}
              </Box>
              <Box width='100%' position='relative'>
                  {hours.map((hour) =>
                      <Box
                          width='100%'
                          height='48px'
                          borderLeft='1px solid lightgray'
                          borderBottom='1px solid lightgray'
                          display='flex'
                          flexDirection='column'
                          alignItems='center'
                          key={`hour-blocks-${hour}`}>
                        {/* comment */}
                      </Box>)}
                  {events}
              </Box>
            </Box>
          </Box>
        </Box>
      </Box>
    )   
  }
}
