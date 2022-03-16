import React, { useState } from "react"
import {
  Text,
  Box,
  Row,
  Button,
  StatelessTextInput,
  Checkbox,
} from "@tlon/indigo-react"
import Calendar, {
  CalendarCreationData,
  CalendarPermission,
  CalendarPermissionsChange,
  DEFAULT_PERMISSIONS,
} from "../types/Calendar"
import { match, RouteComponentProps, withRouter } from "react-router-dom"
import { History, Location, LocationState } from "history"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"
import { formatShip } from "../lib/format"
import { findAdditions, findRemovals } from "../lib/arrays"

interface RouterProps {
  calendar: string
}

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
}

export interface CalendarViewState extends CalendarCreationData {
  prevPath?: Location<LocationState>
}

const CalendarView: React.FC<Props> = ({ history, match }) => {
  const { calendars, getCalendars, saveCalendar, deleteCalendar } =
    useCalendarsAndEvents()
  const { calendar } = match.params
  const selectedCalendar = calendars.find(
    ({ calendarCode }) => calendarCode === calendar
  )

  const initState = (calendar?: Calendar): CalendarViewState => {
    if (calendar) {
      return calendar.toFormFormat()
    }

    return {
      title: "",
      ...DEFAULT_PERMISSIONS,
      changes: [],
      reader: "",
      writer: "",
      acolyte: "",
    }
  }

  const [calendarState, setCalenderState] = useState(
    initState(selectedCalendar)
  )

  const updateValue =
    (type: CalendarPermission) =>
    (e: React.ChangeEvent<HTMLInputElement>): void => {
      const values = {}
      values[type] = e.target.value

      setCalenderState({ ...calendarState, ...values })
    }

  const saveCalendarHandler = async () => {
    let changes: CalendarPermissionsChange[] = []

    const toPermissionsChange =
      (role?: CalendarPermission) =>
      (who: string): CalendarPermissionsChange => ({ who, role })

    if (selectedCalendar) {
      const { readers, writers, acolytes } = selectedCalendar.permissions

      changes = changes.concat(
        findAdditions(readers, calendarState.readers).map(
          toPermissionsChange("reader")
        ),
        findAdditions(writers, calendarState.writers).map(
          toPermissionsChange("writer")
        ),
        findAdditions(acolytes, calendarState.acolytes).map(
          toPermissionsChange("acolyte")
        ),
        findRemovals(
          [...readers, ...writers, ...acolytes],
          [
            ...calendarState.readers,
            ...calendarState.writers,
            ...calendarState.acolytes,
          ]
        ).map(toPermissionsChange(undefined))
      )
    }

    try {
      saveCalendar(calendarState, Boolean(calendarState.calendar))
      await getCalendars()
      history.goBack()
    } catch (e) {
      console.log("SAVE CALENDAR ERROR:", e)
    }
  }

  const deleteCalendarHandler = async (): Promise<void> => {
    const confirmed = await deleteCalendar(calendarState.calendar)
    if (confirmed) {
      history.goBack()
    }
  }

  const changeTitle = (e: React.ChangeEvent<HTMLInputElement>): void => {
    setCalenderState({ ...calendarState, title: e.target.value })
  }

  const disableSave = (): boolean => {
    if (!calendarState.calendar) {
      return !calendarState.title
    }

    return calendarState.calendar.isUnchanged(calendarState)
  }

  const togglePublic = () =>
    setCalenderState({ ...calendarState, public: !calendarState.public })

  const saveDisabled = disableSave()

  const addPermission = (type: CalendarPermission) => () => {
    const cleanedShip = calendarState[type].trim()

    if (cleanedShip) {
      const formattedShip = formatShip(cleanedShip)

      const existing = calendarState[`${type.toString()}s`]
      const newState = {}
      newState[type] = ""

      if (!existing.includes(formattedShip)) {
        newState[`${type.toString()}s`] = existing.concat(formattedShip)
      }

      setCalenderState({ ...calendarState, ...newState })
    }
  }

  const removePermission = (type: CalendarPermission, ship: string) => () => {
    const existing = calendarState[`${type.toString()}s`]
    const newState = {}
    newState[`${type.toString()}s`] = existing.filter((s) => s !== ship)
    setCalenderState({ ...calendarState, ...newState })
  }

  const checkEnter = (type: CalendarPermission) => (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      addPermission(type)()
    }
  }

  const renderListInput = ({
    title,
    buttonText,
    list,
    type,
    removeItem,
    addItem,
    value,
    updateValue,
    checkEnter,
  }) => {
    return (
      <Box marginTop="20px">
        <Text fontSize="1">{title}</Text>
        {!!list.length && (
          <Row>
            {list.map((reader) => (
              <Text
                className="permission"
                marginTop="4px"
                key={reader}
                onClick={removeItem(type, reader)}
              >
                {formatShip(reader)}
              </Text>
            ))}
          </Row>
        )}
        <StatelessTextInput
          onKeyPress={checkEnter(type)}
          fontSize="14px"
          placeholder="Type ship name here"
          width="30%"
          margin="8px 0px 0px"
          onChange={updateValue(type)}
          value={value}
        />
        <Button width="140px" marginTop="8px" onClick={addItem(type)}>
          {buttonText}
        </Button>
      </Box>
    )
  }

  return (
    <Box
      height="100%"
      p="4"
      display="flex"
      flexDirection="column"
      borderWidth={["none", "1px"]}
      borderStyle="solid"
      borderColor="washedGray"
    >
      <Row width="100%">
        <Button fontSize="16px" marginRight="20px" onClick={history.goBack}>
          X
        </Button>
        <StatelessTextInput
          fontSize="1"
          placeholder="Calendar title"
          width="40%"
          marginRight="20px"
          onChange={(e) => changeTitle(e)}
          value={calendarState.title}
        />
        <Button
          disabled={saveDisabled}
          className="dark"
          marginRight="20px"
          onClick={() => saveCalendarHandler()}
        >
          Save
        </Button>
        {!!calendarState.calendar?.title && (
          <Button onClick={() => deleteCalendarHandler()}>Delete</Button>
        )}
      </Row>
      <Row marginTop="20px">
        <Checkbox
          selected={calendarState.public}
          onClick={() => togglePublic()}
        />
        <Text marginLeft="8px">Public</Text>
      </Row>
      {renderListInput({
        title: "Readers",
        buttonText: "Add Reader",
        list: calendarState.readers,
        type: "reader",
        removeItem: removePermission,
        addItem: addPermission,
        value: calendarState.reader,
        updateValue,
        checkEnter,
      })}
      {renderListInput({
        title: "Writers",
        buttonText: "Add Writer",
        list: calendarState.writers,
        type: "writer",
        removeItem: removePermission,
        addItem: addPermission,
        value: calendarState.writer,
        updateValue,
        checkEnter,
      })}
      {renderListInput({
        title: "Acolytes",
        buttonText: "Add Acolyte",
        list: calendarState.acolytes,
        type: "acolyte",
        removeItem: removePermission,
        addItem: addPermission,
        value: calendarState.acolyte,
        updateValue,
        checkEnter,
      })}
      {/* readers */}
      {/* writers */}
      {/* acolytes */}
    </Box>
  )
}

export default withRouter(CalendarView)
