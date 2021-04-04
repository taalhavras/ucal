import React, { Component } from 'react'
import moment from 'moment'

import { BaseInput, Box, Text } from '@tlon/indigo-react'
import { getQuarterHours } from '../../lib/dates'

interface Props {
  selectedTime: string
  selectTime: (time: string) => void
}

interface State {
  showPicker: boolean
}

export default class DatePicker extends Component<Props, State> {
  constructor(props) {
    super(props)

    this.state = { showPicker: false }
  }

  toggleDate = () : void => {
    this.setState({ showPicker: !this.state.showPicker })
  }

  selectTime = (time: string) => () : void => {
    this.props.selectTime(time)
    this.setState({ showPicker: false })
  }

  render() {
    const { props: { selectedTime }, state: { showPicker }, toggleDate, selectTime } = this

    const quarterHours = getQuarterHours()
      
    return <Box>
      <Box margin='16px 0px 0px 12px' padding="8px" borderRadius="4px"
        backgroundColor="#f1f3f4"
        onClick={toggleDate} cursor='pointer'>
        <Text fontSize='14px'>{selectedTime}</Text>
      </Box>
      {showPicker && <Box position='absolute' padding='4px' backgroundColor='white'
        border='1px solid gray' borderRadius='4px' height='200px' overflowY='scroll'>
        {quarterHours.map((time, ind) => <Box key={`time-${ind}`} width='120px'
          className='time-entry' padding='4px' onClick={selectTime(time)}>
          <Text fontSize='14px'>{time}</Text>
        </Box>)}
      </Box>}
    </Box>
  }
}
