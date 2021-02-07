import React, { Component } from 'react';
import _, { capitalize } from 'lodash';

import { Text, Box, Button, StatelessTextInput, StatelessTextArea, Checkbox } from '@tlon/indigo-react';
import moment from 'moment';
import Calendar, { NavDirection, Timeframe } from '../types/Calendar';
import { match, RouteComponentProps, withRouter } from 'react-router-dom';
import { History, Location } from 'history'
import Event, { Era, EventForm, EventLoc, RepeatInterval } from '../types/Event';
import DatePicker from '../components/lib/DatePicker';
import TimePicker from '../components/lib/TimePicker';
import Actions from '../logic/actions';
import { getDefaultStartEndTimes } from '../lib/dates';

const REPEAT_INTERVALS = [RepeatInterval.doesNotRepeat, RepeatInterval.daily, RepeatInterval.weekly, RepeatInterval.monthly, RepeatInterval.yearly]

enum EventField {
  title = 'title',
  location = 'location'
}

interface RouterProps {
  calendar: string
  event: string
}

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
  calendars: Calendar[]
  actions: Actions
  ship: string
}

export interface EventViewState {
  calendarCode?: string
  eventCode?: string
  organizer: string
  title: string
  desc: string
  location: EventLoc
  start: Date
  end: Date
  repeatInterval: RepeatInterval
  startTime: string
  endTime: string
  allDay: boolean
  //TODO: add all event props here
  event: Event
}

class EventView extends Component<Props, EventViewState> {
  constructor(props) {
    super(props)

    const { calendar, event } = props.match.params
    const { events } = (props.calendars.find(({ calendarCode }) => calendarCode === calendar) || { events: [] })
    const eventToEdit = events.find(({ eventCode }) => eventCode === event)

    this.state = {
      ...this.generateState(props),
      ...(eventToEdit || {})
    }
  }

  generateState = (props: Props, event?: Event) : EventViewState => {
    const { startTime, endTime } = getDefaultStartEndTimes()
    return {
      calendarCode: props.calendars[0]?.calendarCode,
      organizer: props.ship,
      title: '',
      desc: '',
      location: new EventLoc({ address: '' }),
      start: new Date(),
      repeatInterval: RepeatInterval.doesNotRepeat,
      end: moment().add(30, 'minutes').toDate(),
      allDay: false,
      startTime,
      endTime,
      event,
    }
}

  static getDerivedStateFromProps = (props: Props, state: EventViewState) => {
    return { ...state, calendarCode: props.calendars[0]?.calendarCode }
  }

  saveEvent = async () => {
    const { state, props, generateState } = this
    const eventToSave = new EventForm(state)
    try {
      if (state.event) {
  
      } else {
        await props.actions.createEvent(eventToSave)
      }
      this.setState(generateState(props))
      props.history.goBack()
    } catch (e) {
      console.log('SAVE EVENT ERROR:', e)
    }
  }

  deleteEvent = () => {

  }

  updateValue = (field: EventField) => (e: React.ChangeEvent<HTMLInputElement>) : void => {
    const values = {}
    if (field === EventField.location) {
      values['location'] = new EventLoc({ address: e.target.value })
    } else {
      values[field] = e.target.value
    }
    
    this.setState(values)
  }

  updateDescription = (e: React.ChangeEvent<HTMLTextAreaElement>) : void => {
    this.setState({ desc: e.target.value })
  }

  selectDate = (isStart: boolean) => (date: Date) => {
    if (isStart) {
      this.setState({ start: date })
    } else {
      this.setState({ end: date })
    }
  }

  selectTime = (isStart: boolean) => (time: string) => {
    if (isStart) {
      this.setState({ startTime: time })
    } else {
      this.setState({ endTime: time })
    }
  }

  toggleAllday = () => {
    this.setState({ allDay: !this.state.allDay })
  }

  setRepeatInterval = (e: React.ChangeEvent<HTMLSelectElement>) : void => {
    e.stopPropagation()
    e.preventDefault()
    this.setState({ repeatInterval: e.target.value as RepeatInterval })
  }

  render() {
    const { state: { title, desc, location, start, end, repeatInterval, event, allDay, startTime, endTime },
      props: { history },
      saveEvent, deleteEvent, updateValue, selectDate, updateDescription, selectTime, toggleAllday,
      setRepeatInterval } = this

    const saveDisabled = !title

    return <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
      <Box width='100%' display='flex' flexDirection='row'>
        <Button fontSize='16px' marginRight='20px' onClick={history.goBack}>X</Button>
        <StatelessTextInput fontSize="1" placeholder="Event title" width='40%' marginRight='20px' onChange={updateValue(EventField.title)} value={title} />
        <Button disabled={saveDisabled} className='dark' marginRight='20px' onClick={saveEvent}>Save</Button>
        {!!(event?.title) && <Button onClick={deleteEvent}>Delete</Button>}
      </Box>
      <Box width='100%' display='flex' flexDirection='row'>
        <DatePicker selectedDay={start} selectDate={selectDate(true)} />
        {!allDay && <TimePicker selectedTime={startTime} selectTime={selectTime(true)} />}
        <Text fontSize="1" margin="28px 12px 0px">to</Text>
        <DatePicker selectedDay={end} selectDate={selectDate(false)} startDate={start} />
        {!allDay && <TimePicker selectedTime={endTime} selectTime={selectTime(false)} />}
      </Box>
      <Box width='100%' display='flex' flexDirection='row' margin='20px 0px 0px' alignItems='center'>
        <Checkbox selected={allDay} onClick={toggleAllday} color='black' />
        <Text fontSize='14px' margin='0px 12px'>All day</Text>
        <Box className="repeat-interval">
          <select value={repeatInterval} onChange={setRepeatInterval}>
            {REPEAT_INTERVALS.map((ri, ind) => <option key={`ri-${ind}`} value={ri.toString()}>
              {ri.toString()}
            </option>)}
          </select>
        </Box>
      </Box>
      <StatelessTextInput fontSize="14px" placeholder="Add location" width='60%' margin="20px 0px 0px" onChange={updateValue(EventField.location)} value={location.address} />
      <StatelessTextArea fontSize="14px" margin="20px 0px 0px" height="160px" placeholder="Add description" width='60%' onChange={updateDescription} value={desc} />
    </Box>
  }
}

export default withRouter(EventView)
