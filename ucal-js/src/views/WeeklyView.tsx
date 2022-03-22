import React, { useState } from "react"
import { Text, Box, Button, Row, Col } from "@tlon/indigo-react"
import moment from "moment"
import Calendar, { Timeframe, ViewProps } from "../types/Calendar"
import { getWeekDays, getHours, HOUR_HEIGHT } from "../lib/dates"
import DateCircle from "../components/lib/DateCircle"
import HoursBar from "../components/lib/HoursBar"
import EventTile from "../components/lib/EventTile"
import { scrollToSelectedDay } from "../lib/position"
import { useUserLocation } from "../hooks/useUserLocation"
import { useCalendarsAndEvents } from "../hooks/useCalendarsAndEvents"
import Modal from "../components/lib/Modal/Modal"

const WeeklyView: React.FC<ViewProps> = ({
  selectedDay,
  displayDay,
  selectDay,
  goToEvent,
  mobile,
}) => {
  const { calendars } = useCalendarsAndEvents()
  const { userLocation } = useUserLocation()
  const days = getWeekDays(selectedDay)
  const month = selectedDay.getMonth()
  const hours = getHours()
  const [selectedAllDayEvents, setSelectedAllDayEvents] = useState(null)
  const [showModal, setShowModal] = useState(false)
  const showEvents = (events: any) => () => {
    setSelectedAllDayEvents(events)
    setShowModal(true)
  }

  return (
    <Box
      display="flex"
      flexDirection="column"
      width="100%"
      margin="16px 0px 0px 0px"
    >
      <Box width="100%" display="flex" flexDirection="row">
        <Box width="calc(12.5% + 2px)" />
        {days.map((day, ind) => {
          const events = Calendar.getRelevantEvents(calendars, day)
          const allDayEvents = events
            .filter(({ allDay }) => allDay)
            .map((e, _ind, events) => (
              <EventTile
                goToEvent={goToEvent}
                weeklyView={false}
                event={e}
                events={events}
                key={`${e.calendarCode}${e.eventCode}`}
                mobile={mobile}
                allDay
              />
            ))

          return (
            <Col
              alignItems="center"
              width="calc(12.5% - 2px)"
              key={`weekday-header-${ind}`}
            >
              <Text color="gray">
                {moment(day).format("ddd").toLocaleUpperCase()}
              </Text>
              <DateCircle
                selectDay={selectDay}
                selectedDay={selectedDay}
                sidebar={false}
                day={day}
                month={month}
              >
                {day.getDate()}
              </DateCircle>
              {allDayEvents.length > 0 && (
                <Button
                  fontSize={13}
                  p={0}
                  my={1}
                  width={60}
                  onClick={showEvents(allDayEvents)}
                >
                  All-day Events
                </Button>
              )}
            </Col>
          )
        })}
      </Box>
      <Box
        width="100%"
        height="calc(100vh - 160px)"
        overflowY="scroll"
        ref={scrollToSelectedDay(Timeframe.week, selectedDay)}
      >
        <Box display="flex" flexDirection="row" width="100%">
          <HoursBar
            displayDay={displayDay}
            userLocation={userLocation}
            mobile={mobile}
          />
          {days.map((day, ind) => {
            const events = Calendar.getRelevantEvents(calendars, day)
            const eventTiles = events
              .filter(({ allDay }) => !allDay)
              .map((e, _ind, events) => (
                <EventTile
                  goToEvent={goToEvent}
                  weeklyView={false}
                  event={e}
                  events={events}
                  key={`${e.calendarCode}${e.eventCode}`}
                  mobile={mobile}
                />
              ))

            return (
              <Box className="weekly-day" key={`weekday-${ind}`}>
                <Box
                  width="100%"
                  height="24px"
                  borderLeft={ind === 0 ? "1px solid lightgray" : "none"}
                  borderRight="1px solid lightgray"
                  borderBottom="1px solid lightgray"
                  display="flex"
                  flexDirection="column"
                  alignItems="center"
                />
                {hours.map((hour) => (
                  <Box
                    width="100%"
                    height={`${HOUR_HEIGHT}px`}
                    borderLeft={ind === 0 ? "1px solid lightgray" : "none"}
                    borderRight="1px solid lightgray"
                    borderBottom="1px solid lightgray"
                    display="flex"
                    flexDirection="column"
                    alignItems="center"
                    key={`hour-${ind}-${hour}`}
                  ></Box>
                ))}
                {eventTiles}
              </Box>
            )
          })}
        </Box>
      </Box>
      <Modal show={showModal} hide={() => setShowModal(false)}>
        <Row width="100%" flexWrap="wrap">
          {selectedAllDayEvents}
        </Row>
      </Modal>
    </Box>
  )
}

export default WeeklyView
