import React, { Component } from 'react'

import { Text, Box, Button } from '@tlon/indigo-react'
import moment from 'moment'
import Calendar, { Timeframe, ViewProps } from '../types/Calendar'
import MonthTile from '../components/lib/MonthTile'
import { scrollToSelectedDay } from '../lib/position'

interface State {
  showDaySummary?: Date
}

export default class YearlyView extends Component<ViewProps, State> {
  constructor(props) {
    super(props)

    this.state = {}
  }

  selectDay = (day: Date) => (event: React.MouseEvent<HTMLElement>) : void => {
    const { props: { selectedDay, selectDay } } = this
    event.preventDefault()
    event.stopPropagation()

    if (!this.state.showDaySummary && selectedDay.getTime() !== day.getTime()) {
      selectDay(day)(event)
    }

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
    const { props: { calendars, selectedDay, goToEvent, createEvent }, state: { showDaySummary },
      selectDay, hideDaySummary } = this

    const events = Calendar.getRelevantEvents(calendars, selectedDay)
      .map((e) => <Text className="yearly-view-event" onClick={goToEvent(e.calendarCode, e.eventCode)} key={`${e.calendarCode}-${e.eventCode}`}>
        {moment(e.getStart()).format('hh:mm')} - {e.title}
      </Text>)

    return (
      <Box display='flex' flexDirection='column' width='100%' height='calc(100vh - 117px)' overflow='scroll' ref={scrollToSelectedDay(Timeframe.year, selectedDay)}>
        <Box display='flex' flexDirection='row' flexWrap='wrap' justifyContent='space-around' onClick={hideDaySummary}>
          {[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map((month) => <Box margin='20px 20px' key={`year-view-${month}`}>
            <MonthTile year={selectedDay.getFullYear()} month={month} {...this.props} selectDay={selectDay} />
          </Box>)}
        </Box>
        {!!showDaySummary && <Box id="yearly-view-modal" onClick={hideDaySummary}>
          <Box className="content">
            <Text textAlign='center' fontSize={1}>{moment(selectedDay).format('ddd, MMMM D - YYYY')}</Text>
            {events.length > 0 && <Box marginTop='16px' display='flex' flexDirection='column'>
              {events}
            </Box>}
            <Button onClick={this.props.selectDay(showDaySummary)} marginTop='16px' width='160px'>
              <Text>See all events</Text>
            </Button>
            <Button onClick={createEvent(selectedDay)} marginTop='16px' width='160px'>
              <Text>Create new event</Text>
            </Button>
          </Box>
        </Box>}
      </Box>
    )   
  }
}
