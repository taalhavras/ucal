import React, { Component } from 'react'

import { Box } from '@tlon/indigo-react'
import Calendar, { Timeframe, ViewProps } from '../types/Calendar'
import { getMonthDays } from '../lib/dates'
import MonthDay from '../components/lib/MonthDay'
import { scrollToSelectedDay } from '../lib/position'

interface State {}

export default class MonthlyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { calendars, selectedDay, selectDay, goToEvent } } = this

    const month = selectedDay.getMonth()
    const days = getMonthDays(selectedDay.getFullYear(), month, true)

    const activeEvents = Calendar.getActiveEvents(calendars)

    return (
      <Box width='100%' display='flex' flexDirection='column' height='calc(100vh - 117px)' overflow='scroll' ref={scrollToSelectedDay(Timeframe.month, selectedDay)}>
        {days.map((week, ind) => <Box width='100%' display='flex' flexDirection='row' key={`week-${ind}`} borderBottom='1px solid lightgray'>
          {week.map((day, i) => <MonthDay goToEvent={goToEvent} selectDay={selectDay} events={activeEvents} day={day} month={month} weekIndex={ind} dayIndex={i} key={`weekday-${ind}-${i}`}/>)}
        </Box>)}
      </Box>
    )   
  }
}
