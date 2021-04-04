import React, { Component } from 'react';
import _, { capitalize } from 'lodash';

import { Text, Box, Row, Button, StatelessTextInput, Checkbox } from '@tlon/indigo-react';
import Calendar, { CalendarCreationData, DEFAULT_PERMISSIONS } from '../types/Calendar';
import { match, RouteComponentProps, useLocation, withRouter } from 'react-router-dom';
import { History, Location, LocationState } from 'history'
import Actions from '../logic/actions';
import { addOrRemove } from '../lib/arrays';

interface RouterProps {
  calendar: string
}

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
  calendars: Calendar[]
  actions: Actions
  ship: string
}

export interface CalendarViewState extends CalendarCreationData {
  prevPath?: Location<LocationState>
}

class CalendarView extends Component<Props, CalendarViewState> {
  constructor(props) {
    super(props)

    const { calendar } = props.match.params
    const selectedCalendar = props.calendars.find(({ calendarCode }) => calendarCode === calendar)

    this.state = {
      ...this.initState(selectedCalendar)
    }
  }

  initState = (calendar?: Calendar) : CalendarViewState => {
    if (calendar) {
      return calendar.toFormFormat()
    }

    return {
      title: '',
      ...DEFAULT_PERMISSIONS,
    }
  }

  saveCalendar = async () => {
    const { props, state } = this
    try {
      props.actions.saveCalendar({ ...state }, Boolean(state.calendar))
      props.history.goBack()
    } catch (e) {
      console.log('SAVE CALENDAR ERROR:', e)
    }
  }

  deleteCalendar = async () : Promise<void> => {
    const { props: { actions, history }, state: { calendar, prevPath } } = this
    const confirmed = await actions.deleteCalendar(calendar)
    if (confirmed) {
      history.goBack()
    }
  }

  changeTitle = (e: React.ChangeEvent<HTMLInputElement>) : void => {
    this.setState({ title: e.target.value })
  }

  disableSave = () : boolean => {
    const { state } = this
    if (!state.calendar) {
      return !state.title
    }

    return state.calendar.isUnchanged(state)
  }

  togglePublic = () => this.setState({ public: !this.state.public })

  render() {
    const { state, state: { title, calendar },
      props: { history },
      disableSave, deleteCalendar, saveCalendar, changeTitle,
      togglePublic } = this

    const saveDisabled = disableSave()

    return <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
      <Row width='100%'>
        <Button fontSize='16px' marginRight='20px' onClick={history.goBack}>X</Button>
        <StatelessTextInput fontSize="1" placeholder="Calendar title" width='40%' marginRight='20px' onChange={changeTitle} value={title} />
        <Button disabled={saveDisabled} className='dark' marginRight='20px' onClick={saveCalendar}>Save</Button>
        {!!(calendar?.title) && <Button onClick={deleteCalendar}>Delete</Button>}
      </Row>
      <Row marginTop="20px">
        <Checkbox selected={state.public} onClick={togglePublic} />
        <Text marginLeft="8px">Public</Text>
      </Row>
      {/* readers */}
      {/* writers */}
      {/* acolytes */}
      {/* public */}
    </Box>
  }
}

export default withRouter(CalendarView)
