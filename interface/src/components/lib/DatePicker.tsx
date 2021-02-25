import React, { Component } from 'react'
import moment from 'moment'

import { BaseInput, Box, Text } from '@tlon/indigo-react'
import MonthTile from './MonthTile'

interface Props {
  selectedDay: Date
  startDate?: Date
  selectDate: (date: Date) => void
}

interface State {
  showCalendar: boolean
}

export default class DatePicker extends Component<Props, State> {
  constructor(props) {
    super(props)

    this.state = { showCalendar: false }
  }

  toggleDate = () : void => {
    this.setState({ showCalendar: !this.state.showCalendar })
  }

  selectDate = (date: Date) => () : void => {
    this.props.selectDate(date)
    this.setState({ showCalendar: false })
  }

  render() {
    const { props: { selectedDay, startDate }, state: { showCalendar }, toggleDate, selectDate } = this

    const endAfterStart = startDate && moment(startDate).startOf('day').isAfter(selectedDay)
      
    return <Box>
      <Box margin='20px 0px 0px' padding="8px" borderRadius="4px" backgroundColor={endAfterStart ? "#fce8e6" : "#f1f3f4"}
        onClick={toggleDate} cursor='pointer'>
        <Text fontSize='14px'>{moment(selectedDay).format('MMM D, YYYY')}</Text>
      </Box>
      {showCalendar && <Box position='absolute' padding='4px' backgroundColor='white' border='1px solid gray' borderRadius='4px'>
        <MonthTile {...this.props} showNavArrows showYear displayDay={selectedDay} selectDay={selectDate} />
      </Box>}
    </Box>
  }
}
