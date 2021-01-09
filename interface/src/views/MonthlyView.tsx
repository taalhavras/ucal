import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import { ViewProps } from '../types/Calendar'
import { getMonthDays } from '../lib/dates'
import DateCircle from '../components/lib/DateCircle'

interface State {}

export default class MonthlyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { calendars, selectedDay, selectDay } } = this

    const month = selectedDay.getMonth()
    const days = getMonthDays(selectedDay.getFullYear(), month, true)

    return (
      <Box width='100%' display='flex' flexDirection='column' height='calc(100vh - 117px)' overflow='scroll'>
        {days.map((week, ind) => <Box width='100%' display='flex' flexDirection='row' key={`week-${ind}`} borderBottom='1px solid lightgray'>
          {week.map((day, i) => <Box width='14.285%' height={ind === 0 ? '120px' : '106px'} paddingTop='8px' borderLeft={i === 0 ? '1px solid lightgray' : 'none'} borderRight='1px solid lightgray' display='flex' flexDirection='column' alignItems='center' key={`weekday-${ind}-${i}`}>
            {ind === 0 && <Text opacity='0.5'>{moment(day).format('ddd').toLocaleUpperCase()}</Text>}
            <DateCircle {...this.props} day={day} month={month} shaded={month !== day.getMonth()}>{day.getDate()}</DateCircle>
          </Box>)}
        </Box>)}
      </Box>
    )   
  }
}
