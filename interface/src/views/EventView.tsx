import React, { Component } from 'react';
import _, { capitalize } from 'lodash';

import { Text, Box, Button, StatelessTextInput } from '@tlon/indigo-react';
import moment from 'moment';
import Calendar, { NavDirection, Timeframe } from '../types/Calendar';
import { match, RouteComponentProps, withRouter } from 'react-router-dom';
import { Location, History } from 'history'
import Event from '../types/Event';

enum EventField {
  title = 'title',
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
}

interface State {
  title?: string
  //TODO: add all event props here
  event: Event
}

class EventView extends Component<Props, State> {
  constructor(props) {
    super(props)

    const { calendar, event } = props.match.params;

    const eventToEdit = (props.calendars.find(({ id }) => id == calendar) || { events: [] }).events.find(({ id }) => id == event)

    this.state = {
      event: eventToEdit,
      ...(eventToEdit || {})
    }
  }

  updateValue = (field: EventField) => (e: React.ChangeEvent<HTMLInputElement>) : void => {
    const values = {}
    values[field] = e.target.value
    this.setState(values)
  }

  render() {
    const { state: { title }, updateValue } = this
    
    return <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
      <Box width='100%' display='flex' flexDirection='row'>
        <Button fontSize='16px' marginRight='20px'>X</Button>
        <StatelessTextInput width='40%' marginRight='20px' onChange={updateValue(EventField.title)} />
        <Button className='dark' marginRight='20px'>Save</Button>
        <Button>Delete</Button>
      </Box>
      <Box width='100%' display='flex' flexDirection='row'>

      </Box>
    </Box>
  }
}

export default withRouter(EventView)
