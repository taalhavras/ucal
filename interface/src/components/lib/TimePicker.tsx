import React, { useState } from "react"
import { Box, Text } from "@tlon/indigo-react"
import { getQuarterHours } from "../../lib/dates"
interface Props {
  selectedTime: string
  selectTime: (time: string) => void
}

const TimePicker: React.FC<Props> = ({ selectedTime, selectTime }) => {
  const [showPicker, setShowPicker] = useState(false)
  const toggleDate = (): void => {
    setShowPicker(!showPicker)
  }

  const selectTimeHandler = (time: string) => (): void => {
    selectTime(time)
    setShowPicker(false)
  }

  const quarterHours = getQuarterHours()

  return (
    <Box>
      <Box
        margin="16px 0px 0px 12px"
        padding="8px"
        borderRadius="4px"
        backgroundColor="white"
        onClick={toggleDate}
        cursor="pointer"
      >
        <Text fontSize="14px">{selectedTime}</Text>
      </Box>
      {showPicker && (
        <Box
          position="absolute"
          padding="4px"
          backgroundColor="white"
          border="1px solid gray"
          borderRadius="4px"
          height="200px"
          overflowY="scroll"
        >
          {quarterHours.map((time, ind) => (
            <Box
              key={`time-${ind}`}
              width="120px"
              className="time-entry"
              padding="4px"
              onClick={selectTimeHandler(time)}
            >
              <Text fontSize="14px">{time}</Text>
            </Box>
          ))}
        </Box>
      )}
    </Box>
  )
}

export default TimePicker
