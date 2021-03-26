import React, { Component } from 'react';
import _, { capitalize } from 'lodash';

import { Text, Box, Button, Checkbox, Row, Icon } from '@tlon/indigo-react';
import moment from 'moment'
import Calendar, { NavDirection, Timeframe } from '../types/Calendar'
import WeeklyView from './WeeklyView'
import DailyView from './DailyView'
import MonthlyView from './MonthlyView'
import YearlyView from './YearlyView'
import Title from '../components/lib/Title'
import MonthTile from '../components/lib/MonthTile'
import { match, RouteComponentProps, withRouter } from 'react-router-dom'
import { Location, History } from 'history'
import Actions from '../logic/actions'
import { HOUR_HEIGHT } from '../lib/dates';

interface RouterProps {
  timeframe: string
  displayDay: string
}

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
  calendars: Calendar[]
  actions: Actions
  userLocation: string
}

interface State {
  timeframe: Timeframe
  displayDay: Date
  selectedDay: Date
  showCalendarModal: boolean
}

class CalendarWrapper extends Component<Props, State> {
  constructor(props) {
    super(props)

    const { timeframe, displayDay } = props.match.params;

    const useTf = (timeframe && timeframe as Timeframe) || Timeframe.month
    const useDd = (displayDay && moment(displayDay).toDate()) || new Date()

    this.state = {
      timeframe: useTf,
      displayDay: useDd,
      selectedDay: useDd,
      showCalendarModal: false,
    }
  }

  goToToday = () : void => {
    const displayDay = new Date()
    this.pushViewRoute(this.state.timeframe, displayDay)
    this.setState({ displayDay, selectedDay: displayDay })
  }

  selectTimeframe = (e: React.ChangeEvent<HTMLSelectElement>) : void => {
    e.stopPropagation()
    e.preventDefault()
    const timeframe = e.target.value as Timeframe
    this.pushViewRoute(timeframe, this.state.selectedDay)
    this.setState({ timeframe })
  }

  selectDay = (isSidebar?: boolean) => (selectedDay: Date) => () : void => {
    let timeframe = Timeframe.day
    if (isSidebar) {
      timeframe = this.state.timeframe
    }
    else if (this.state.timeframe === Timeframe.year && this.state.selectedDay.getTime() !== selectedDay.getTime()) {
      timeframe = Timeframe.year
    }
    this.pushViewRoute(timeframe, selectedDay)
    this.setState({ selectedDay, timeframe, displayDay: selectedDay })
  }

  changeRange = (direction: NavDirection) => () => {
    const { state: { displayDay, timeframe, selectedDay } } = this
    const newDisplay = moment(displayDay)[direction](1, timeframe).toDate()
    const newSelected = newDisplay
    
    this.pushViewRoute(timeframe, newSelected)
    this.setState({ displayDay: newDisplay, selectedDay: newSelected })
  }

  pushViewRoute = (tf: Timeframe, dd: Date) : void => this.props.history.push(`/~calendar/${tf}/${moment(dd).format('YYYY-MM-DD')}`)

  createEvent = (day?: Date) => () => this.props.history.push(`/~calendar/event${day ? `?date=${day?.getTime()}` : ''}`)

  goToEvent = (calendarCode: string, eventCode: string) => () : void => {
    this.props.history.push(`/~calendar/event/${calendarCode}/${eventCode}`)
  }

  hideCalendarModal = (e?: React.MouseEvent<HTMLElement>) => {
    e?.preventDefault()
    e?.stopPropagation()
    this.setState({ showCalendarModal: false })
  }

  addCalendar = () => {
    this.setState({ showCalendarModal: true })
  }

  createCalendar = (calendarCode?: string) => () => {
    this.hideCalendarModal()
    this.props.history.push(`/~calendar/${calendarCode ? `calendar/edit/${calendarCode}` : 'create'}`)
  }

  deleteCalendar = (calendar: Calendar) => () => this.props.actions.deleteCalendar(calendar)

  render() {
    const {
      props: { calendars, userLocation, actions: { toggleCalendar } },
      state: { timeframe, selectedDay, showCalendarModal },
      selectDay, changeRange, createEvent, goToEvent, addCalendar, createCalendar,
      hideCalendarModal, deleteCalendar
    } = this

    let layout = <WeeklyView {...this.props} {...this.state} selectDay={selectDay()} goToEvent={goToEvent} createEvent={createEvent} />
    switch (timeframe) {
      case Timeframe.day:
        layout = <DailyView {...this.props} {...this.state} selectDay={selectDay()} goToEvent={goToEvent} createEvent={createEvent} />
        break;
      case Timeframe.month:
        layout = <MonthlyView {...this.props} {...this.state} selectDay={selectDay()} goToEvent={goToEvent} createEvent={createEvent} />
        break;
      case Timeframe.year:
        layout = <YearlyView {...this.props} {...this.state} selectDay={selectDay()} goToEvent={goToEvent} createEvent={createEvent} />
        break;
    }

    return <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
      <Box width='100%' display='flex' flexDirection='row' justifyContent='space-between' borderBottom='1px solid lightGray' paddingBottom='12px'>
        <Box height='100%' display='flex' flexDirection='row'>
          <Text pt='4' border='2px solid black' borderRadius='4px' height='12px' padding='2px 3px' margin='5px 8px 0px 0px'>{moment().format('DD')}</Text>
          <Text fontSize='1' margin={`6px ${HOUR_HEIGHT}px 0px 0px`}>Calendar</Text>
          <Button onClick={this.goToToday}>Today</Button>

          <Box height='100%' display='flex' flexDirection='row' margin='0px 24px'>
            <Button onClick={changeRange(NavDirection.left)} fontSize='3' border='none'>&lsaquo;</Button>
            <Button onClick={changeRange(NavDirection.right)} fontSize='3' border='none'>&rsaquo;</Button>
          </Box>

          <Title {...this.state} />
        </Box>

        <Box height='100%' display='flex' flexDirection='row' padding='0px 8px' border='1px solid rgba(0, 0, 0, 0.3)' borderRadius='4px'>
          <select className='timeframe' value={timeframe} onChange={this.selectTimeframe}>
            {Object.values(Timeframe).map((tf, ind) => <option value={tf} key={`timeframe-${ind}`}>
                    {capitalize(tf)}
                  </option>)}
          </select>
        </Box>
      </Box>
      <Row width='100%'>
        <Box display='flex' flexDirection='column' margin='32px 2% 0px 0px'>
          <Button onClick={createEvent()} marginBottom='20px' width='100px'><Text fontSize='20px'>+</Text> <Text margin='2px 0px 0px 6px' fontSize='14px'>Create</Text></Button>
          <MonthTile {...this.state} selectDay={selectDay(true)} showYear showNavArrows selectedDay={selectedDay} />
          <Text fontSize='1' margin='20px 0px 0px 0px'>Calendars</Text>
          {calendars.map((cal, ind) => <Row className='calendar-selector' key={`cal-${ind}`}>
            <Row>
              <Checkbox selected={cal.active} onClick={toggleCalendar(cal)} />
              <Text marginLeft="8px">{cal.owner} - {cal.title}</Text>
            </Row>
            <Row className='edit-icon'>
              <Icon icon='Ellipsis' color='black' onClick={createCalendar(cal.calendarCode)} />
              <Icon icon='TrashCan' color='black' onClick={deleteCalendar(cal)} />
            </Row>
          </Row>)}
          <Button onClick={addCalendar} marginTop='16px' width='120px'><Text fontSize='12px'>Add Calendar</Text></Button>
        </Box>
        
        {layout}
      </Row>

      {showCalendarModal && <Box onClick={hideCalendarModal} id='create-calendar-modal' className='modal'>
        <Box className='content' onClick={(e) => e.stopPropagation()}>
          <Button onClick={createCalendar()} marginTop='16px' maxWidth='200px'><Text fontSize='14px'>Create Calendar</Text></Button>
        </Box>
      </Box>}
    </Box>
  }
}

export default withRouter(CalendarWrapper)
