import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import { ViewProps } from '../types/Calendar'
import MonthTile from '../components/lib/MonthTile'

interface State {
  showDaySummary?: Date
}

export default class YearlyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)

    this.state = {}
  }

  selectDay = (day: Date) => (event: React.MouseEvent<HTMLElement>) : void => {
    event.preventDefault()
    event.stopPropagation()
    this.props.selectDay(day)(event)
    if (day.getTime() === this.state.showDaySummary?.getTime()) {
      this.setState({ showDaySummary: undefined })
    } else {
      this.setState({ showDaySummary: day })
    }
  }

  hideDaySummary = () => {
    this.setState({ showDaySummary: undefined })
  }

  render() {
    const { props: { selectedDay }, state: { showDaySummary }, selectDay, hideDaySummary } = this

    console.log(showDaySummary)

    return (
      <Box display='flex' flexDirection='column' width='100%' height='calc(100vh - 117px)' overflow='scroll'>
        {!!showDaySummary && <Box margin='auto' width="300px" height="400px" backgroundColor="white" position="relative" top="0">

        </Box>}
        <Box display='flex' flexDirection='row' flexWrap='wrap' justifyContent='space-around' onClick={hideDaySummary}>
          {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((month) => <Box margin='20px 20px' key={`year-view-${month}`}>
            <MonthTile year={selectedDay.getFullYear()} month={month} {...this.props} selectDay={selectDay} />
          </Box>)}
        </Box>
      </Box>
    )   
  }
}
