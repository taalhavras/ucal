import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import { ViewProps } from '../types/Calendar'
import MonthTile from '../components/lib/MonthTile'

interface State {}

export default class YearlyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { selectedDay } } = this
    return (
      <Box display='flex' flexDirection='column' width='100%' height='calc(100vh - 117px)' overflow='scroll'>
        <Box display='flex' flexDirection='row' flexWrap='wrap' justifyContent='space-around'>
          {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((month) => <Box margin='20px 20px' key={`year-view-${month}`}>
            <MonthTile year={selectedDay.getFullYear()} month={month} {...this.props} />
          </Box>)}
        </Box>
      </Box>
    )   
  }
}
