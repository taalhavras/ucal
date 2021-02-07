import React, { Component } from 'react';
import _, { capitalize } from 'lodash';

import { Text, Box, Button, Checkbox } from '@tlon/indigo-react';
import moment from 'moment';
import Calendar, { NavDirection, Timeframe } from '../types/Calendar';
import WeeklyView from './WeeklyView';
import DailyView from './DailyView';
import MonthlyView from './MonthlyView';
import YearlyView from './YearlyView';
import Title from '../components/lib/Title';
import MonthTile from '../components/lib/MonthTile';
import { match, RouteComponentProps, withRouter } from 'react-router-dom';
import { Location, History } from 'history'
import Actions from '../logic/actions';

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
}

class CalendarView extends Component<Props, State> {
  constructor(props) {
    super(props)

    const { timeframe, displayDay } = props.match.params;

    const useTf = (timeframe && timeframe as Timeframe) || Timeframe.month
    const useDd = (displayDay && moment(displayDay).toDate()) || new Date()

    this.state = {
      timeframe: useTf,
      displayDay: useDd,
      selectedDay: useDd,
    }
  }

  goToToday = () : void => {
    const displayDay = new Date()
    this.pushViewRoute(this.state.timeframe, displayDay)
    this.setState({ displayDay, selectedDay: displayDay })
  }

  selectTimeframe = (event: React.ChangeEvent<HTMLSelectElement>) : void => {
    event.stopPropagation()
    event.preventDefault()
    const timeframe = event.target.value as Timeframe
    this.pushViewRoute(timeframe, this.state.selectedDay)
    this.setState({ timeframe })
  }

  selectDay = (isSidebar?: boolean) => (selectedDay: Date) => () : void => {
    let timeframe = Timeframe.day
    if (isSidebar) {
      timeframe = this.state.timeframe
    }
    else if (this.state.timeframe === Timeframe.year) {
      timeframe = Timeframe.year
      //TODO: show a popup w/ list of events, and option to create
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

  createEvent = () => this.props.history.push('/~calendar/event')

  render() {
    const { props: { calendars, userLocation }, state: { timeframe, displayDay, selectedDay }, selectDay, changeRange, createEvent } = this
    let layout = <WeeklyView calendars={calendars} {...this.state} selectDay={selectDay()} />
    switch (timeframe) {
      case Timeframe.day:
        layout = <DailyView history={this.props.history} calendars={calendars} userLocation={userLocation} {...this.state} selectDay={selectDay()} />
        break;
      case Timeframe.month:
        layout = <MonthlyView calendars={calendars} userLocation={userLocation} {...this.state} selectDay={selectDay()} />
        break;
      case Timeframe.year:
        layout = <YearlyView calendars={calendars} userLocation={userLocation} {...this.state} selectDay={selectDay()} />
        break;
    }

    return <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
      <Box width='100%' display='flex' flexDirection='row' justifyContent='space-between' borderBottom='1px solid lightGray' paddingBottom='12px'>
        <Box height='100%' display='flex' flexDirection='row'>
          <Text pt='4' border='2px solid black' borderRadius='4px' height='12px' padding='2px 3px' margin='5px 8px 0px 0px'>{moment().format('DD')}</Text>
          <Text fontSize='1' margin='6px 48px 0px 0px'>Calendar</Text>
          <Button onClick={this.goToToday}>Today</Button>

          <Box height='100%' display='flex' flexDirection='row' margin='0px 24px'>
            <Button onClick={changeRange(NavDirection.left)} fontSize='3' border='none'>&lsaquo;</Button>
            <Button onClick={changeRange(NavDirection.right)} fontSize='3' border='none'>&rsaquo;</Button>
          </Box>

          <Title {...this.state} />
        </Box>

        <Box height='100%' display='flex' flexDirection='row' margin='0px 24px' padding='0px 8px' border='1px solid rgba(0, 0, 0, 0.3)' borderRadius='4px'>
          <select className='timeframe' value={timeframe} onChange={this.selectTimeframe}>
            {Object.values(Timeframe).map((tf, ind) => <option value={tf} key={`timeframe-${ind}`}>
                    {capitalize(tf)}
                  </option>)}
          </select>
        </Box>
      </Box>
      <Box width='100%' display='flex' flexDirection='row'>
        <Box display='flex' flexDirection='column' margin='32px 2% 0px 0px'>
          <Button onClick={createEvent} marginBottom='20px' width='100px'><Text fontSize='20px'>+</Text> <Text margin='2px 0px 0px 6px' fontSize='14px'>Create</Text></Button>
          <MonthTile {...this.state} selectDay={selectDay(true)} showYear showNavArrows selectedDay={selectedDay} />
          <Text fontSize='1' margin='20px 0px 12px 0px'>Calendars</Text>
          {calendars.map((cal, ind) => <Box display='flex' flexDirection='row' key={`cal-${ind}`}>
            <Checkbox selected={cal.active} />
            <Text marginLeft="8px">{cal.owner}_{cal.title}</Text>
          </Box>)}
        </Box>
        
        {layout}
      </Box>
    {/* <Text pt='3'>Welcome to your Calendar.</Text>
    <Text pt='3'>To get started, edit <code>src/index.js</code> or <code>urbit/app/calendar.hoon</code> and <code>|commit %home</code> on your Urbit ship to see your changes.</Text> */}
  </Box>
  }
}

export default withRouter(CalendarView)
