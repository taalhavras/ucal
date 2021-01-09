import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import { ViewProps } from '../types/Calendar'
import { getWeekDays, getHours } from '../lib/dates'
import DateCircle from '../components/lib/DateCircle'

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
            <Box display='flex' flexDirection='column' width='12.5%' alignItems='flex-end'>
              {hours.map((hour) => <Text color='rgba(0,0,0, 0.6)' margin={hour === 0 ? '16px 12px 0px 0px' : '32px 12px 0px 0px'} key={`hour-${hour}`}>{hour}:00</Text>)}
            </Box>
            {days.map((day, ind) => <Box display='flex' flexDirection='column' alignItems='center' width='12.5%' key={`weekday-${ind}`}>
              <Box width='100%' height='24px' borderLeft={ind === 0 ? '1px solid lightgray' : 'none'} borderRight='1px solid lightgray' borderBottom='1px solid lightgray' display='flex' flexDirection='column' alignItems='center'>
              </Box>
              {hours.map((hour) => <Box width='100%' height='48px' borderLeft={ind === 0 ? '1px solid lightgray' : 'none'} borderRight='1px solid lightgray' borderBottom='1px solid lightgray' display='flex' flexDirection='column' alignItems='center' key={`hour-${ind}-${hour}`}>

              </Box>)}
            </Box>)}
          </Box>
        </Box>
      </Box>
    )   
  }
}
