import React, { useState } from "react"
import {
  Text,
  Box,
  Button,
  StatelessTextInput,
  StatelessTextArea,
  Checkbox,
  Row,
} from "@tlon/indigo-react"
import moment from "moment"
import {
  match,
  RouteComponentProps,
  withRouter,
  useHistory,
} from "react-router-dom"
import { Location, LocationState } from "history"
import Event, {
  EventForm,
  EventLoc,
  InviteChange,
  RepeatInterval,
  Weekday,
  WEEKDAYS,
} from "../types/Event"
import DatePicker from "../components/lib/DatePicker"
import TimePicker from "../components/lib/TimePicker"
import { getDefaultStartEndTimes } from "../lib/dates"
import { addOrRemove, findAdditions, findRemovals } from "../lib/arrays"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"
import { formatShip } from "../lib/format"

const REPEAT_INTERVALS = [
  RepeatInterval.doesNotRepeat,
  RepeatInterval.daily,
  RepeatInterval.weekly,
  RepeatInterval.monthly,
  RepeatInterval.yearly,
]

enum EventField {
  title = "title",
  location = "location",
  invite = "invite",
}

interface RouterProps {
  calendar: string
  event: string
}

interface Props extends RouteComponentProps<RouterProps> {
  location: Location
  match: match<RouterProps>
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
  weekdays: Weekday[]
  startTime: string
  endTime: string
  allDay: boolean
  invited: string[]
  invite: string
  //TODO: add all event props here
  event?: Event
  prevPath?: Location<LocationState>
  inviteChanges?: InviteChange[]
}

const EventView: React.FC<Props> = ({ location, match }) => {
  const history = useHistory()
  const { calendars, saveEvent, deleteEvent, getEvents } =
    useCalendarsAndEvents()
  const { calendar, event } = match.params
  const { events } = calendars.find(
    ({ calendarCode }) => calendarCode === calendar
  ) || { events: [] }
  const eventToEdit = events.find(({ eventCode }) => eventCode === event)

  const getCalendarCode = () =>
    (
      calendars.find((c) => c.title === "default" && c.owner === window.ship) ||
      calendars[0]
    )?.calendarCode

  const dateQueryParam = new URLSearchParams(location.search).get("date")
  const start = dateQueryParam ? new Date(Number(dateQueryParam)) : new Date()
  const end = moment(start).add(30, "minutes").toDate()

  const initState = (event?: Event): EventViewState => {
    const { startTime, endTime } = getDefaultStartEndTimes()
    if (event) {
      return event.toFormFormat()
    }

    return {
      calendarCode: getCalendarCode(),
      organizer: window.ship,
      title: "",
      desc: "",
      location: new EventLoc({ address: "" }),
      start,
      end,
      repeatInterval: RepeatInterval.doesNotRepeat,
      weekdays: [moment(start).format("ddd").toLowerCase() as Weekday],
      allDay: false,
      startTime,
      endTime,
      invited: [],
      invite: "",
    }
  }

  const [eventState, setEventState] = useState<EventViewState>({
    ...initState(eventToEdit),
    weekdays: [moment(start).format("ddd").toLowerCase() as Weekday],
  })

  const saveEventHandler = async () => {
    const updated = Boolean(eventState.event)

    const eventToSave = new EventForm({
      ...eventState,
      inviteChanges: updated
        ? [
            ...findAdditions(
              eventState?.event?.invitedShips() || [],
              eventState.invited
            ).map((who) => ({ who, invite: true })),
            ...findRemovals(
              eventState?.event?.invitedShips() || [],
              eventState.invited
            ).map((who) => ({ who, invite: false })),
          ]
        : undefined,
    })

    try {
      const updated = Boolean(eventState.event)
      saveEvent(eventToSave, updated)
      setEventState(initState())
      await getEvents()
      history.goBack()
    } catch (e) {
      console.error("SAVE EVENT ERROR:", e)
    }
  }

  const deleteEventHandler = async (): Promise<void> => {
    if (
      eventState.event &&
      confirm("Are you sure you want to delete this event?")
    ) {
      deleteEvent(eventState.event)
      await getEvents()
      history.replace(eventState.prevPath || "/")
    }
  }

  const updateValueHandler = (
    e: React.ChangeEvent<HTMLInputElement>,
    field: EventField
  ): void => {
    e.preventDefault()
    const values = {}
    if (field === EventField.location) {
      values["location"] = new EventLoc({ address: e.target.value })
    } else {
      values[field] = e.target.value
    }

    setEventState({ ...eventState, ...values })
  }

  const updateDescriptionHandler = (
    e: React.ChangeEvent<HTMLTextAreaElement>
  ): void => {
    setEventState({ ...eventState, desc: e.target.value })
  }

  const selectDate = (isStart: boolean) => (date: Date) => {
    if (isStart) {
      setEventState({ ...eventState, start: date })
    } else {
      setEventState({ ...eventState, end: date })
    }
  }

  const selectTime = (isStart: boolean) => (time: string) => {
    if (isStart) {
      setEventState({ ...eventState, startTime: time })
    } else {
      setEventState({ ...eventState, endTime: time })
    }
  }

  const toggleAllday = () => {
    setEventState({ ...eventState, allDay: !eventState.allDay })
  }

  const setRepeatInterval = (e: React.ChangeEvent<HTMLSelectElement>): void => {
    e.stopPropagation()
    e.preventDefault()
    setEventState({
      ...eventState,
      repeatInterval: e.target.value as RepeatInterval,
    })
  }

  const selectCalendar = (e: React.ChangeEvent<HTMLSelectElement>): void => {
    setEventState({ ...eventState, calendarCode: e.target.value as string })
  }

  const disableSave = (): boolean => {
    if (!eventState.event) {
      return !eventState.title
    }

    return eventState.event.isUnchanged(eventState)
  }

  const toggleWeekday = (weekday: Weekday) => (): void => {
    setEventState({
      ...eventState,
      weekdays: addOrRemove(eventState.weekdays, weekday),
    })
  }
  const saveDisabled = disableSave()

  const addInvite = () => {
    const { invite, invited } = eventState
    const cleanedShip = invite.trim()

    if (cleanedShip) {
      const formattedShip = formatShip(cleanedShip)

      if (
        !invited.includes(formattedShip) &&
        !(formattedShip === `~${window.ship}`)
      ) {
        setEventState({
          ...eventState,
          invited: invited.concat(formattedShip),
          invite: "",
        })
      } else {
        setEventState({ ...eventState, invite: "" })
      }
    }
  }

  const removeInvite = (ship) => () =>
    setEventState({
      ...eventState,
      invited: addOrRemove(eventState.invited, ship),
    })

  const checkEnter = (e: React.KeyboardEvent) => {
    if (e.key === "Enter") {
      addInvite()
    }
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
      <Box width="100%" display="flex" flexDirection="row">
        <Button fontSize="16px" marginRight="20px" onClick={history.goBack}>
          X
        </Button>
        <StatelessTextInput
          fontSize="1"
          placeholder="Event title"
          width="40%"
          marginRight="20px"
          onChange={(e) => updateValueHandler(e, EventField.title)}
          value={eventState.title}
        />
        <Button
          disabled={saveDisabled}
          className="dark"
          marginRight="20px"
          onClick={() => saveEventHandler()}
        >
          Save
        </Button>
        {!!eventState.event?.title && (
          <Button onClick={() => deleteEventHandler()}>Delete</Button>
        )}
      </Box>

      <Row className="calendar-select">
        <Text margin="6px 8px 0px 0px" fontSize="14px">
          Calendar:{" "}
        </Text>
        <select
          value={eventState.calendarCode}
          onChange={(e) => selectCalendar(e)}
        >
          {calendars.map((c, ind) => (
            <option key={`select-calendar-${ind}`} value={c.calendarCode}>
              {c.title}
            </option>
          ))}
        </select>
      </Row>

      <Box width="100%" display="flex" flexDirection="row">
        <DatePicker
          selectedDay={eventState.start}
          selectDate={selectDate(true)}
        />
        {!eventState.allDay && (
          <TimePicker
            selectedTime={eventState.startTime}
            selectTime={selectTime(true)}
          />
        )}
        <Text fontSize="1" margin="24px 12px 0px">
          to
        </Text>
        <DatePicker
          selectedDay={eventState.end}
          selectDate={selectDate(false)}
          startDate={eventState.start}
        />
        {!eventState.allDay && (
          <TimePicker
            selectedTime={eventState.endTime}
            selectTime={selectTime(false)}
          />
        )}
      </Box>

      <Box
        width="100%"
        display="flex"
        flexDirection="row"
        margin="20px 0px 0px"
        alignItems="center"
      >
        <Checkbox
          selected={eventState.allDay}
          onClick={toggleAllday}
          color="black"
        />
        <Text fontSize="14px" margin="0px 12px">
          All day
        </Text>
        <Box className="repeat-interval">
          <select
            value={eventState.repeatInterval}
            onChange={(e) => setRepeatInterval(e)}
          >
            {REPEAT_INTERVALS.map((ri, ind) => (
              <option key={`ri-${ind}`} value={ri.toString()}>
                {ri.toString()}
              </option>
            ))}
          </select>
        </Box>
        {eventState.repeatInterval === RepeatInterval.weekly && (
          <Box
            display="flex"
            flexDirection="row"
            alignItems="center"
            marginLeft="16px"
          >
            {WEEKDAYS.map((weekday) => (
              <Box
                className={`weekday ${
                  eventState.weekdays.includes(weekday) ? "selected" : ""
                }`}
                onClick={toggleWeekday(weekday)}
                key={`weekday-${weekday}`}
              >
                <Text fontWeight="bold">{weekday[0].toUpperCase()}</Text>
              </Box>
            ))}
          </Box>
        )}
      </Box>

      <Text fontSize="1" marginTop="20px">
        Invites
      </Text>
      <Row marginTop={eventState.invited.length && "12px"}>
        {eventState.invited.map((ship, ind) => (
          <Text
            className="invite"
            key={`ship-${ship}`}
            onClick={removeInvite(ship)}
          >
            {ind > 0 ? `, ${ship}` : ship}
          </Text>
        ))}
      </Row>
      <StatelessTextInput
        onKeyPress={checkEnter}
        fontSize="14px"
        placeholder="Type ship name here"
        width="30%"
        margin="20px 0px 0px"
        onChange={(e) => updateValueHandler(e, EventField.invite)}
        value={eventState.invite}
      />
      <Button width="120px" marginTop="8px" onClick={addInvite}>
        Add Invite
      </Button>

      {!!eventState.event?.invited?.length && (
        <Box marginTop="20px">
          <Text fontSize="1">RSVPs</Text>
          <Box>
            {eventState.event.invited.map(({ ship, status }, ind) => (
              <Row key={`rsvp-${ship}`} marginTop="8px">
                <Text>
                  {ship} : {status || "no response"}
                </Text>
              </Row>
            ))}
          </Box>
        </Box>
      )}

      <StatelessTextInput
        fontSize="14px"
        placeholder="Add location"
        width="60%"
        margin="20px 0px 0px"
        onChange={(e) => updateValueHandler(e, EventField.location)}
        value={eventState?.location?.address}
      />
      <StatelessTextArea
        fontSize="14px"
        margin="20px 0px 0px"
        height="160px"
        placeholder="Add description"
        width="60%"
        onChange={(e) => updateDescriptionHandler(e)}
        value={eventState?.desc}
      />
    </Box>
  )
}

export default withRouter(EventView)
