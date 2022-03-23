import React, { useState } from "react"
import moment from "moment"
import { Box, Text } from "@tlon/indigo-react"
import MonthTile from "./MonthTile"
import { DropdownBackground } from "./DropdownBackground"

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
        margin="20px 0px 4px"
        padding="4px 8px"
        borderRadius="4px"
        backgroundColor={endAfterStart ? "#fce8e6" : "white"}
        onClick={toggleDate}
        cursor="pointer"
        border="1px solid lightGray"
      >
        <Text fontSize="14px">{moment(selectedDay).format("MMM D, YYYY")}</Text>
      </Box>
      {showCalendar && (
        <>
          <DropdownBackground onClick={toggleDate} />
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
        </>
      )}
    </Box>
  )
}

export default DatePicker
