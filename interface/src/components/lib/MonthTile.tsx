import React, { Component, useState } from "react"

import { Text, Box, Button } from "@tlon/indigo-react"
import moment from "moment"
import { NavDirection } from "../../types/Calendar"
import DateCircle from "./DateCircle"
import { getMonthDays } from "../../lib/dates"

interface Props {
  selectedDay: Date
  sidebar?: boolean
  displayDay: Date
  year?: number
  month?: number
  showYear?: boolean
  showNavArrows?: boolean
  selectDay: (
    day: Date,
    sidebar?: boolean
  ) => (event: React.MouseEvent<HTMLElement>) => void
  changeRange?: (direction: NavDirection) => () => void
}

const MonthTile: React.FC<Props> = ({
  selectedDay,
  sidebar,
  displayDay,
  year,
  month,
  showYear,
  showNavArrows,
  selectDay,
  changeRange,
}) => {
  const [displayDayState, setDisplayDayState] = useState(displayDay)

  const changeRangeHandler = (dir: NavDirection) => (): void => {
    if (changeRange) {
      changeRange(dir)()
    } else {
      const newDisplay = moment(displayDayState)[dir](1, "month").toDate()
      setDisplayDayState(newDisplay)
    }
  }
  const monthLocal = month === undefined ? displayDayState.getMonth() : month
  const yearLocal = year || displayDayState.getFullYear()
  const days = getMonthDays(yearLocal, monthLocal)

  return (
    <Box display="flex" flexDirection="column">
      <Box display="flex" flexDirection="row" justifyContent="space-between">
        <Text
          fontSize="14px"
          margin="4px 0px 8px 8px"
          opacity={
            showYear || moment().get("month") === monthLocal ? "0.9" : "0.6"
          }
        >
          {moment({ year: yearLocal, month: monthLocal }).format(
            showYear ? "MMMM YYYY" : "MMMM"
          )}
        </Text>
        {!!showNavArrows && (
          <Box
            display="flex"
            flexDirection="row"
            justifyContent="space-between"
          >
            <Button
              height="24px"
              onClick={changeRangeHandler(NavDirection.left)}
              fontSize="2"
              border="none"
            >
              &lsaquo;
            </Button>
            <Button
              height="24px"
              onClick={changeRangeHandler(NavDirection.right)}
              fontSize="2"
              border="none"
            >
              &rsaquo;
            </Button>
          </Box>
        )}
      </Box>
      <Box display="flex" flexDirection="column">
        <Box display="flex" flexDirection="row">
          {["S", "M", "T", "W", "T", "F", "S"].map((v, i) => (
            <DateCircle
              month={monthLocal}
              shaded
              key={`header-${monthLocal}-${i}`}
            >
              {v}
            </DateCircle>
          ))}
        </Box>
        {days.map((week, ind) => (
          <Box
            display="flex"
            flexDirection="row"
            key={`${monthLocal}-week-${ind}`}
          >
            {week.map((day, i) => (
              <DateCircle
                selectDay={selectDay}
                sidebar={sidebar}
                month={monthLocal}
                shaded={day.getMonth() !== monthLocal}
                selectedDay={selectedDay}
                day={day}
                key={`${monthLocal}-${ind}-${i}`}
              >
                {day.getDate()}
              </DateCircle>
            ))}
          </Box>
        ))}
      </Box>
    </Box>
  )
}

export default MonthTile
