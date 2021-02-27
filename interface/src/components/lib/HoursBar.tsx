import React, { Component } from 'react'
import moment from 'moment'
import SunCalc from 'suncalc'

import { Box, Text, Row } from '@tlon/indigo-react'
import styled from "styled-components";
import { getHours, HOUR_HEIGHT, FIRST_HOUR_MARGIN, padTime } from '../../lib/dates'

const toRelativeTime = (date, referenceTime, unit) => moment(referenceTime)
  .diff(date, unit)

const minsToPct = (mins) => {
  // 1440 = total minutes in an earth day
  return (mins / 1440) * 100
}

const convert = (date, referenceTime) => {
  const percentageOfDay = minsToPct(toRelativeTime(date, referenceTime, 'minutes'))
  const positivePercentage = percentageOfDay < 0 ? -percentageOfDay : (100 - percentageOfDay)

  return positivePercentage
}

const Hour = styled(Text)`
  color: ${p => p.theme.colors.gray}
`;

interface Props {
  displayDay: Date
  userLocation: string
}

export default class HoursBar extends Component<Props> {
  constructor(props) {
    super(props)
  }

  render() {
    const loc = this.props.userLocation.includes(',') && this.props.userLocation || '40.4, -74.5'
    const [lat, lon] = loc.split(',')

    const referenceTime = moment(this.props.displayDay).startOf('day')
    const suncalc = SunCalc.getTimes(moment(referenceTime).toDate(), lat, lon)

    const dayParts = {
      sunset: convert(suncalc.sunset, referenceTime),
      sunrise: convert(suncalc.sunrise, referenceTime),
      sunsetStart: convert(suncalc.sunsetStart, referenceTime),
      sunriseEnd: convert(suncalc.sunriseEnd, referenceTime),
      dusk: convert(suncalc.dusk, referenceTime),
      dawn: convert(suncalc.dawn, referenceTime),
      night: convert(suncalc.night, referenceTime),
      nightEnd: convert(suncalc.nightEnd, referenceTime),
      nauticalDawn: convert(suncalc.nauticalDawn, referenceTime),
      nauticalDusk: convert(suncalc.nauticalDusk, referenceTime)
    }

    const preDayNight = dayParts.nightEnd
    const sunrise1 = (dayParts.sunriseEnd - dayParts.nightEnd) / 2
    const sunrise2 = (dayParts.sunriseEnd - dayParts.nightEnd) / 2
    const day = dayParts.sunset - dayParts.sunriseEnd
    const sunset1 = (dayParts.night - dayParts.sunset) / 2
    const sunset2 = (dayParts.night - dayParts.sunset) / 2
    const postDayNight = 100 - dayParts.night

    const hours = getHours()

    return <Row width='12.5%' display='flex' justifyContent='space-around'>
      <Box height='calc(100% - 24px)' marginTop='24px'>
        <Row height={preDayNight+'%'}>
          <Box width='40px' maxWidth='20px'
              background='rgba(0, 0, 0, .8)'>
          </Box>
        </Row>
        <Row height={sunrise1+'%'}>
          <Box width='40px' maxWidth='20px'
              background='rgba(255, 65, 54, .8)'>
          </Box>
        </Row>
        <Row height={sunrise2+'%'}>
          <Box width='40px' maxWidth='20px'
              background='#FFC700'>
          </Box>
        </Row>
        <Row height={day+'%'}>
          <Box width='40px' maxWidth='20px'
              background='rgba(33, 157, 255, .2)'>
          </Box>
        </Row>
        <Row height={sunset1+'%'}>
          <Box width='40px' maxWidth='20px'
              background='#FCC440'>
          </Box>
        </Row>
        <Row height={sunset2+'%'}>
          <Box width='40px' maxWidth='20px'
              background='rgba(255, 65, 54, .8)'>
          </Box>
        </Row>
        <Row height={postDayNight+'%'}>
          <Box width='40px' maxWidth='20px'
              background='rgba(0, 0, 0, .8)'>
          </Box>
        </Row>
      </Box>
      <Box display='flex' flexDirection='column' alignItems='flex-end'>
        {hours.map((hour) =>
          <Hour
            margin={hour === 0 ? `${FIRST_HOUR_MARGIN}px 4px 0px 0px` : `${HOUR_HEIGHT - FIRST_HOUR_MARGIN}px 4px 0px 0px`}
            key={`hour-${hour}`}>
            {padTime(hour)}:00
          </Hour>)}
      </Box>
    </Row> 
  }
}


