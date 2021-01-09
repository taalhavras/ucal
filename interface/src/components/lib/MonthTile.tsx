import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import Calendar, { NavDirection } from '../../types/Calendar'
import DateCircle from './DateCircle'
import { getMonthDays } from '../../lib/dates'

interface Props {
  selectedDay: Date
  displayDay: Date
  year?: number
  month?: number
  calendars: Calendar[]
  showYear?: boolean
  showNavArrows?: boolean
  selectDay: (day: Date) => () => void
  changeRange?: (direction: NavDirection) => () => void
}

interface State {}

class MonthTile extends Component<Props, State> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { showYear, selectedDay, displayDay, changeRange } } = this

    const month = this.props.month === undefined ? displayDay.getMonth() : this.props.month
    const year = this.props.year || displayDay.getFullYear()
    const days = getMonthDays(year, month)

    return (
      <Box display='flex' flexDirection='column'>
        <Box display='flex' flexDirection='row' justifyContent='space-between'>
          <Text fontSize='14px' margin='4px 0px 8px 8px' opacity={showYear || moment().get('month') === month ? '0.9' : '0.6'}>{moment({ year, month }).format(showYear ? 'MMMM YYYY' : 'MMMM')}</Text>
          {!!changeRange && <Box display='flex' flexDirection='row' justifyContent='space-between'>
            <Button height='24px' onClick={changeRange(NavDirection.left)} fontSize='2' border='none'>&lsaquo;</Button>
            <Button height='24px' onClick={changeRange(NavDirection.right)} fontSize='2' border='none'>&rsaquo;</Button>
          </Box>}
        </Box>
        <Box display='flex' flexDirection='column'>
          <Box display='flex' flexDirection='row'>
            {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((v, i) => <DateCircle month={month} shaded key={`header-${month}-${i}`}>{v}</DateCircle>)}
          </Box>
          {days.map((week, ind) => <Box display='flex' flexDirection='row' key={`${month}-week-${ind}`}>
            {week.map((day, i) => <DateCircle {...this.props} month={month} shaded={day.getMonth() !== month} selectedDay={selectedDay} day={day} key={`${month}-${ind}-${i}`}>{day.getDate()}</DateCircle>)}
          </Box>)}
        </Box>
      </Box>
    )   
  }
}

export default MonthTile
