import React from "react"
import moment from "moment"

import { Box, Text } from "@tlon/indigo-react"
import { Timeframe } from "../../types/Calendar"
import { getFirstOfWeek, getLastOfWeek, spansMonths } from "../../lib/dates"

interface Props {
  timeframe: Timeframe
  selectedDay: Date
}

const Title: React.FC<Props> = ({ timeframe, selectedDay }) => {
  const multipleMonths =
    timeframe === Timeframe.week && spansMonths(selectedDay)

  if (multipleMonths) {
    return (
      <Box height="100%" display="flex" flexDirection="row" margin="8px 24px">
        <Text fontSize="1" border="none">
          {moment(getFirstOfWeek(selectedDay)).format("MMM YYYY")}
        </Text>
        <Text fontSize="1" margin="0px 12px">
          &ndash;
        </Text>
        <Text fontSize="1" border="none">
          {moment(getLastOfWeek(selectedDay)).format("MMM YYYY")}
        </Text>
      </Box>
    )
  } else if (timeframe === Timeframe.year) {
    return (
      <Box
        height="100%"
        display="flex"
        flexDirection="row"
        margin="6px 24px 5px"
      >
        <Text fontSize="20px" border="none">
          {moment(selectedDay).format("YYYY")}
        </Text>
      </Box>
    )
  }

  return (
    <Box height="100%" display="flex" flexDirection="row" margin="8px 24px">
      <Text fontSize="1" border="none">
        {moment(selectedDay).format("MMMM YYYY")}
      </Text>
    </Box>
  )
}

export default Title
