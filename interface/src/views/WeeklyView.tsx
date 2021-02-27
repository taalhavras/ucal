import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import Calendar, { ViewProps } from '../types/Calendar'
import { getWeekDays, getHours, HOUR_HEIGHT } from '../lib/dates'
import DateCircle from '../components/lib/DateCircle'
import HoursBar from '../components/lib/HoursBar'
import EventTile from '../components/lib/EventTile'

interface State {}

export default class WeeklyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { calendars, selectedDay, selectDay } } = this
    const days = getWeekDays(selectedDay)
    const month = selectedDay.getMonth()
    const hours = getHours()

    return (
      <Box display='flex' flexDirection='column' width='100%' margin='16px 0px 0px 0px'>
        <Box width='100%' display='flex' flexDirection='row'>
          <Box width='calc(12.5% - 2px)'/>
          {days.map((day, ind) => <Box display='flex' flexDirection='column' alignItems='center' width='calc(12.5% - 2px)' key={`weekday-header-${ind}`}>
            <Text color='rgba(0,0,0,0.6)'>{moment(day).format('ddd').toLocaleUpperCase()}</Text>
            <DateCircle {...this.props} day={day} month={month}>{day.getDate()}</DateCircle>
          </Box>)}
        </Box>
        <Box width='100%' height='calc(100vh - 160px)' overflowY='scroll'>
          <Box display='flex' flexDirection='row' width='100%'>
            <HoursBar {...this.props} />
            {days.map((day, ind) => {
              const events = Calendar.getRelevantEvents(calendars, day)
                .map((e, _ind, events) => (<EventTile
                  {...this.props}
                  event={e}
                  events={events}
                  weeklyView={true}
                  key={`${e.calendarCode}${e.eventCode}`}
                />))

              return <Box className="weekly-day" key={`weekday-${ind}`}>
                <Box width='100%' height='24px' borderLeft={ind === 0 ? '1px solid lightgray' : 'none'} borderRight='1px solid lightgray' borderBottom='1px solid lightgray' display='flex' flexDirection='column' alignItems='center' />
                {hours.map((hour) => <Box
                  width='100%'
                  height={`${HOUR_HEIGHT}px`}
                  borderLeft={ind === 0 ? '1px solid lightgray' : 'none'}
                  borderRight='1px solid lightgray'
                  borderBottom='1px solid lightgray'
                  display='flex'
                  flexDirection='column'
                  alignItems='center'
                  key={`hour-${ind}-${hour}`}>
                </Box>)}
                {events}
              </Box>
            })}
          </Box>
        </Box>
      </Box>
    )   
  }
}
