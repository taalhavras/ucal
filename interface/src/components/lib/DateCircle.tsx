import React, { Component } from 'react'
import moment from 'moment'

import { Text } from '@tlon/indigo-react'

interface Props {
  selectDay?: (day: Date) => () => void
  shaded?: boolean
  day?: Date
  selectedDay?: Date
  month: number
}

export default class DateCircle extends Component<Props> {
  constructor(props) {
    super(props)
  }

  render() {
    const { props: { selectDay, day, selectedDay, month } } = this
    const isToday = !!day && moment(day).isSame(moment(), 'day')
    const isSelected = !!day && !!selectedDay && moment(day).isSame(moment(selectedDay), 'day') && selectedDay.getMonth() === month
    let className = 'date-circle'
    let onClick
    if (selectDay) {
      className += ' clickable'
      onClick = selectDay(day)
    }
    if (isToday) {
      className += ' today'
    }
    if (isSelected) {
      className += ' selected'
    }

    return (
      <Text className={className} onClick={onClick} padding='5px 1px' width='24px' margin='1px 4px' borderRadius='13px' textAlign='center' verticalAlign='middle' opacity={!!this.props.shaded ? '0.5' : '0.9'}>
        {this.props.children}
      </Text>
    )   
  }
}
