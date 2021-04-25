import React, { Component } from 'react';
import _, { capitalize, update } from 'lodash';

import { Text, Box, Row, Button, StatelessTextInput, Checkbox } from '@tlon/indigo-react';
import Calendar, { CalendarCreationData, DEFAULT_PERMISSIONS, CalendarPermission, CalendarPermissionsChange } from '../types/Calendar';
import { match, RouteComponentProps, useLocation, withRouter } from 'react-router-dom';
import { History, Location, LocationState } from 'history'
import Actions from '../logic/actions';
import { formatShip } from '../lib/format';

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
  prevPath?: Location<LocationState>,
  selectedCalendar?: Calendar,
  reader: string,
  writer: string,
  acolyte: string,
}

class CalendarView extends Component<Props, CalendarViewState> {
  constructor(props) {
    super(props)

    const { calendar } = props.match.params
    const selectedCalendar = props.calendars.find(({ calendarCode }) => calendarCode === calendar)

    this.state = {
      ...this.initState(selectedCalendar),
      selectedCalendar
    }
  }

  initState = (calendar?: Calendar) : CalendarViewState => {
    if (calendar) {
      return calendar.toFormFormat()
    }

    return {
      title: '',
      ...DEFAULT_PERMISSIONS,
      changes: [],
      reader: '',
      writer: '',
      acolyte: '',
    }
  }

  saveCalendar = async () => {
    const { props, state } = this

    let changes : CalendarPermissionsChange[] = []

    const toPermissionsChange = (role: CalendarPermission) => (who: string) : CalendarPermissionsChange => ({ who, role })
    const findAdditions = (current: string[], changes: string[], role: CalendarPermission) =>
      changes.filter((change) => !current.includes(change)).map(toPermissionsChange(role))
      // find all of the users who were in the old lists (combined) but no longer are in any
    const findRemovals = (current: string[], changes: string[]) => current.filter((cur) => !changes.includes(cur)).map(toPermissionsChange(undefined))

    if (state.selectedCalendar) {
      const { readers, writers, acolytes } = state.selectedCalendar.permissions

      changes = changes.concat(
        findAdditions(readers, state.readers, 'reader'),
        findAdditions(writers, state.writers, 'writer'),
        findAdditions(acolytes, state.acolytes, 'acolyte'),
        findRemovals([...readers, ...writers, ...acolytes], [...state.readers, ...state.writers, ...state.acolytes]),
      )
    }

    try {
      props.actions.saveCalendar({ ...state, changes }, Boolean(state.calendar))
      props.history.goBack()
    } catch (e) {
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

  updateValue = (type: CalendarPermission) => (e: React.ChangeEvent<HTMLInputElement>) : void => {
    const values = {}
    values[type] = e.target.value
    
    this.setState(values)
  }

  addPermission = (type: CalendarPermission) => () => {
    const cleanedShip = this.state[type].trim()

    if (cleanedShip) {
      const formattedShip = formatShip(cleanedShip)

      const existing = this.state[`${type.toString()}s`]
      const newState = {}
      newState[type] = ''

      if (!existing.includes(formattedShip)) {
        newState[`${type.toString()}s`] = existing.concat(formattedShip)
      }

      this.setState(newState)
    }
  }

  removePermission = (type: CalendarPermission, ship: string) => () => {
    const existing = this.state[`${type.toString()}s`]
    const newState = {}
    newState[`${type.toString()}s`] = existing.filter((s) => s !== ship)
    this.setState(newState)
  }

  checkEnter = (type: CalendarPermission) => (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      this.addPermission(type)();
    }
  }

  renderListInput = ({
    title, buttonText, list, type, removeItem, addItem, value, updateValue, checkEnter, 
  }) => {
    return <Box marginTop='20px'>
      <Text fontSize='1'>{title}</Text>
      {!!list.length && <Row>
        {list.map((reader) => <Text className='permission' marginTop='4px' key={reader} onClick={removeItem(type, reader)}>
          {formatShip(reader)}
        </Text>)}
      </Row>}
      <StatelessTextInput onKeyPress={checkEnter(type)} fontSize="14px" placeholder="Type ship name here" width='30%' margin="8px 0px 0px" onChange={updateValue(type)} value={value} />
      <Button width='120px' marginTop='8px' onClick={addItem(type)}>{buttonText}</Button>
    </Box>
  }

  render() {
    const { state, state: { title, calendar, readers, writers, acolytes, reader, writer, acolyte },
      props: { history },
      disableSave, deleteCalendar, saveCalendar, changeTitle, removePermission,
      togglePublic, checkEnter, addPermission, updateValue } = this

    const saveDisabled = disableSave()

    return <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
      <Row width='100%'>
        <Button fontSize='16px' marginRight='20px' onClick={history.goBack}>X</Button>
        <StatelessTextInput fontSize="1" placeholder="Calendar title" width='40%' marginRight='20px' onChange={changeTitle} value={title} />
        <Button disabled={saveDisabled} className={saveDisabled ? 'disabled dark' : 'dark'} marginRight='20px' onClick={saveCalendar}>Save</Button>
        {!!(calendar?.title) && <Button onClick={deleteCalendar}>Delete</Button>}
      </Row>
      <Row marginTop="20px">
        <Checkbox selected={state.public} onClick={togglePublic} />
        <Text marginLeft="8px">Public</Text>
      </Row>
      {this.renderListInput({
        title: 'Readers',
        buttonText: 'Add Reader',
        list: readers,
        type: 'reader',
        removeItem: removePermission,
        addItem: addPermission,
        value: reader,
        updateValue,
        checkEnter,
      })}
      {this.renderListInput({
        title: 'Writers',
        buttonText: 'Add Writer',
        list: writers,
        type: 'writer',
        removeItem: removePermission,
        addItem: addPermission,
        value: writer,
        updateValue,
        checkEnter,
      })}
      {this.renderListInput({
        title: 'Acolytes',
        buttonText: 'Add Acolyte',
        list: acolytes,
        type: 'acolyte',
        removeItem: removePermission,
        addItem: addPermission,
        value: acolyte,
        updateValue,
        checkEnter,
      })}
    </Box>
  }
}

export default withRouter(CalendarView)
