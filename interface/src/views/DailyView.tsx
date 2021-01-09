import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import { ViewProps } from '../types/Calendar'
import { getHours } from '../lib/dates'
import HoursBar from '../components/lib/HoursBar'

interface State {}

export default class DailyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { calendars, selectedDay, selectDay } } = this
    const hours = getHours()
    const selectedMoment = moment(selectedDay)

    return (
      <Box display='flex' flexDirection='column' width='100%' margin='16px 0px 0px 0px'>
        <Box marginLeft='14%' display='flex' flexDirection='column' width='40px' alignItems='center'>
          <Text color='rgba(0,0,0,0.6)'>{selectedMoment.format('ddd').toLocaleUpperCase()}</Text>
          <Text fontSize='2' color='rgba(0,0,0,0.6)'>{selectedMoment.format('D').toLocaleUpperCase()}</Text>
        </Box>
        <Box width='100%' height='calc(100vh - 162px)' overflowY='scroll'>
          <Box display='flex' flexDirection='row' width='100%'>
            <HoursBar {...this.props} userLocation='' />
            <Box display='flex' flexDirection='column' width='87.5%' alignItems='flex-end'>
              <Box width='100%' height='24px' borderLeft='1px solid lightgray' borderBottom='1px solid lightgray' display='flex' flexDirection='column' alignItems='center'>
                {/* this is for all-day events */}
              </Box>
              {hours.map((hour) => <Box width='100%' height='48px' borderLeft='1px solid lightgray' borderBottom='1px solid lightgray' display='flex' flexDirection='column' alignItems='center' key={`hour-blocks-${hour}`}>
                {/* this is for events by hour */}
              </Box>)}
            </Box>
          </Box>
        </Box>
      </Box>
    )   
  }
}
