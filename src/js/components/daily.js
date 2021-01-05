import React, { Component } from 'react';
import SunCalc from 'suncalc';
import dark from './themes/dark';
import light from './themes/light';
import moment from "moment"
import styled, { ThemeProvider, createGlobalStyle } from 'styled-components';
import { Box, Row, Text } from '@tlon/indigo-react';
import { daToUnix } from '../lib/util.js';

const convertToFraction = (date, referenceTime) => {
  return minsToDegs(toRelativeTime(date, referenceTime, 'minutes'));
};

const toRelativeTime = (date, referenceTime, unit) => moment(date)
  .diff(referenceTime, unit);

const minsToPct = (mins) => {
  // 1440 = total minutes in an earth day
  return (mins / 1440) * 100;
};

const convert = (date, referenceTime) => {
  return minsToPct(toRelativeTime(date, referenceTime, 'minutes'));
};

const splitArc = (start, end) => end + ((start - end) * 0.5);
const DATESTAMP_FORMAT = '[~]YYYY.M.D';

class CalendarEvent extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    const { props } = this;
    const { title, color, subtitle, startTime, endTime, referenceTime } = props;
    const s = moment(startTime);
    const e = moment(endTime);
    const duration = moment.duration(e.diff(s)).asHours();
    const topDistance = moment.duration(startTime.diff(referenceTime)).asHours();
    return (
      <Box
          height={(duration * 80) + 'px'}
          width='80%'
          backgroundColor={color}
          position='absolute'
          left='50px'
          top={(topDistance * 80) + 'px'}>
        <Row>
          <Text paddingLeft='0.3rem' paddingTop='0.3rem' bold fontSize={1}>{title}</Text>
        </Row>
        <Row>
          <Text paddingLeft='0.3rem' paddingTop='0.3rem'>{subtitle}</Text>
        </Row>
      </Box>
    );
  }
};

export class Daily extends Component {
  constructor(props) {
    super(props);
    //this.state = {
    //  body: '',
    //  title: '',
    //  submit: false,
    //  awaiting: null,
    //  disabled: false
    //};

    //this.postSubmit = this.postSubmit.bind(this);
    //this.titleChange = this.titleChange.bind(this);
    //this.bodyChange = this.bodyChange.bind(this);
  }
  
  setupMockEvents()
  {

    this.events.push({
      color: 'green',
      title: 'Workout',
      subtitle: 'gym time',
      startTime: moment(suncalc.nightEnd),
      endTime: moment(suncalc.sunriseEnd)
    });

    this.events.push({
      color: 'green',
      title: 'Breakfast',
      subtitle: '',
      startTime: moment(suncalc.sunriseEnd).add(30, 'minute'),
      endTime: moment(suncalc.sunriseEnd).add(60, 'minute')
    });

    this.events.push({
      color:'blue',
      title:'Urbit calendar discussion',
      subtitle:'~wolref-podlex/calendar--ucal--4800',
      startTime: moment().startOf('day').add(10, 'hour'),
      endTime: moment().startOf('day').add(11, 'hour').subtract(10, 'minute'),
    });

    this.events.push({
      color:'blue',
      title:'Write some code',
      subtitle:'',
      startTime: moment().startOf('day').add(13, 'hour'),
      endTime: moment().startOf('day').add(17, 'hour').subtract(10, 'minute')
    });

    this.events.push({
      color:'green',
      title:'Dinner',
      subtitle:'Cook some good stuff',
      startTime: moment(suncalc.sunset),
      endTime: moment(suncalc.night)
    });
  }
  render() {
    const { props, state } = this;
    const referenceTime = moment(props.day);

    const startDay = moment(referenceTime);
    const endDay = moment(startDay).add(1, 'day');

    let eventsData = [];
    if (props.allEvents != undefined)
    {
        eventsData = props.allEvents
            .filter((e) => {
                let startTime = moment.utc(e.data.start);
                return startTime.isAfter(startDay) && startTime.isBefore(endDay);
            })
            .map((e) => ({
                color: 'green',
                title: e.data.title,
                subtitle: e.data.desc,
                startTime: moment.utc(e.data.start),
                endTime: moment.utc(e.data.end),
                key: e.data['event-code'],
            }));
    }

    let loc = props.userLocation;
    if (loc === undefined)
    {
        loc = "37, -122";
    }
    const latlon = loc.split(',');
    const lat = latlon[0];
    const lon = latlon[1];

    const suncalc = SunCalc.getTimes(moment(referenceTime).local().startOf('day').add(1, 'day').toDate(), lat, lon);

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
    };

    const preDayNight = dayParts.nightEnd;
    const sunrise1 = (dayParts.sunriseEnd - dayParts.nightEnd) / 2;
    const sunrise2 = (dayParts.sunriseEnd - dayParts.nightEnd) / 2;
    const day = dayParts.sunset - dayParts.sunriseEnd;
    const sunset1 = (dayParts.night - dayParts.sunset) / 2;
    const sunset2 = (dayParts.night - dayParts.sunset) / 2;
    const postDayNight = 100 - dayParts.night;

    const hour = (h) => {
        return (
          <Row key={h} position='relative' height='80px'>
            <Box width='max(50vw, 300px)' maxWidth='40px' position='relative' top='-10px'>
              <Text>{h}</Text>
            </Box>
            <Box height='80px' width='100%' borderColor='scales.black100' borderTop='1px solid'>
              <Text></Text>
            </Box>
          </Row>
        );
    }

    var hours = [];

    for (var i = 0; i < 24; ++i)
    {
        hours.push(
            hour(
                moment()
                .startOf('day')
                .add(i, 'hour')
                .format('HH:mm')
            )
        );
    }

    let events = eventsData.map((e) => (<CalendarEvent
        color={e.color}
        title={e.title}
        subtitle={e.subtitle}
        startTime={e.startTime}
        endTime={e.endTime}
        key={e.key}
        referenceTime={referenceTime}
        />));

    const nowLine = convert(moment(), referenceTime) + '%';

    return (
      <Box height='100%' overflow='auto'>
        <Row justifyContent='center'>
          <Box width='max(50vw, 300px)' maxWidth='580px' position='relative'>
            {hours}
            {events}
            <Box position='absolute' top={nowLine} width='100%'>
              <hr color='#FF4036'/>
            </Box>
          </Box>
          <Box>
            <Row height={preDayNight+'%'}>
              <Box width='max(50vw, 300px)' maxWidth='20px'
                   background='rgba(255, 65, 54, .2)'>
              </Box>
            </Row>
            <Row height={sunrise1+'%'}>
              <Box width='max(50vw, 300px)' maxWidth='20px'
                   background='rgba(255, 65, 54, .8)'>
              </Box>
            </Row>
            <Row height={sunrise2+'%'}>
              <Box width='max(50vw, 300px)' maxWidth='20px'
                   background='#FFC700'>
              </Box>
            </Row>
            <Row height={day+'%'}>
              <Box width='max(50vw, 300px)' maxWidth='20px'
                   background='rgba(33, 157, 255, .2)'>
              </Box>
            </Row>
            <Row height={sunset1+'%'}>
              <Box width='max(50vw, 300px)' maxWidth='20px'
                   background='#FCC440'>
              </Box>
            </Row>
            <Row height={sunset2+'%'}>
              <Box width='max(50vw, 300px)' maxWidth='20px'
                   background='rgba(255, 65, 54, .8)'>
              </Box>
            </Row>
            <Row height={postDayNight+'%'}>
              <Box width='max(50vw, 300px)' maxWidth='20px'
                   background='rgba(255, 65, 54, .2)'>
              </Box>
            </Row>
          </Box>
        </Row>
      </Box>
    );
  }
};

export default Daily;
