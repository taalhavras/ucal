import React, { useState } from "react"
import moment from "moment"

import { Box, Text } from "@tlon/indigo-react"
import MonthTile from "./MonthTile"

interface Props {
  selectedDay: Date
  startDate?: Date
  selectDate: (date: Date) => void
}

const DatePicker: React.FC<Props> = ({
  selectedDay,
  startDate,
  selectDate,
}) => {
  const [showCalendar, setShowCalendar] = useState(false)
  const toggleDate = (): void => {
    setShowCalendar(!showCalendar)
  }

  const selectDateHandler = (date: Date) => (): void => {
    selectDate(date)
    setShowCalendar(false)
  }
  const endAfterStart =
    startDate && moment(startDate).startOf("day").isAfter(selectedDay)

  return (
    <Box>
      <Box
        margin="16px 0px 0px"
        padding="8px"
        borderRadius="4px"
        backgroundColor={endAfterStart ? "#fce8e6" : "#f1f3f4"}
        onClick={toggleDate}
        cursor="pointer"
      >
        <Text fontSize="14px">{moment(selectedDay).format("MMM D, YYYY")}</Text>
      </Box>
      {showCalendar && (
        <Box
          position="absolute"
          padding="4px"
          backgroundColor="white"
          border="1px solid gray"
          borderRadius="4px"
        >
          <MonthTile
            selectedDay={selectedDay}
            sidebar={false}
            showNavArrows
            showYear
            displayDay={selectedDay}
            selectDay={selectDateHandler}
          />
        </Box>
      )}
    </Box>
  )
}

export default DatePicker
