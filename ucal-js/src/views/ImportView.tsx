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
  DEFAULT_PERMISSIONS,
} from "../types/Calendar"
import { match, RouteComponentProps, withRouter } from "react-router-dom"
import { History, Location, LocationState } from "history"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"

interface RouterProps {
  calendar: string
}

interface Props extends RouteComponentProps<RouterProps> {
  history: History
  location: Location
  match: match<RouterProps>
}

export interface ImportViewState extends CalendarCreationData {
  prevPath?: Location<LocationState>
}

const ImportView: React.FC<Props> = ({ history, match }) => {
  const { calendars, getCalendars, saveCalendar, deleteCalendar } =
    useCalendarsAndEvents()
  const { calendar } = match.params
  const selectedCalendar = calendars.find(
    ({ calendarCode }) => calendarCode === calendar
  )

  const importCalendar = async (url: string): Promise<void> => {
    console.log("IMPORTING FROM: ", url)
    let response = await fetch(url)
    if (!response.ok) {
      // NOCOMMIT what should the real error handling be? we probably want to
      // just alert the user somehow... not sure what the best way to thread
      // that info back is? throwing + caller catching and redirecting?
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const blob = response.blob()
    if (blob.type != "text/calendar") {
      throw new Error(
        `Data at ${url} had type ${blob.type} instead of text/calendar`
      )
    }

    await api.action("ucal-store", "ucal-action", {
      "import-from-ics": {
        data: blob.text(),
      },
    })
  }

  const saveCalendarHandler = async () => {
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
          placeholder="URL title"
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
      {/* readers */}
      {/* writers */}
      {/* acolytes */}
      {/* public */}
    </Box>
  )
}

export default withRouter(ImportView)
