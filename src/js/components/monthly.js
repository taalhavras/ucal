import moment from "moment"
import React, { Component } from 'react';

import styled, { ThemeProvider, createGlobalStyle } from 'styled-components';
import light from './themes/light';
import dark from './themes/dark';

import { daToUnix } from '../lib/util.js';

import { Box, Row, Text } from '@tlon/indigo-react';

export class Monthly extends Component {
  constructor(props) {
    super(props);
  }
  
  render() {
    const { props, state } = this;

    return (
      <Box width='100%'>
        <Row>
          <Box justifyContent='center' width='14%'><Text position='relative' fontSize='1'>Monday</Text></Box>
          <Box justifyContent='center' width='14%'><Text position='relative' fontSize='1'>Tuesday</Text></Box>
          <Box justifyContent='center' width='14%'><Text position='relative' fontSize='1'>Wednesday</Text></Box>
          <Box justifyContent='center' width='14%'><Text position='relative' fontSize='1'>Thursday</Text></Box>
          <Box justifyContent='center' width='14%'><Text position='relative' fontSize='1'>Friday</Text></Box>
          <Box justifyContent='center' width='14%'><Text position='relative' fontSize='1'>Saturday</Text></Box>
          <Box justifyContent='center' width='14%'><Text position='relative' fontSize='1'>Sunday</Text></Box>
        </Row>
      </Box>
    );
    return (<Box></Box>);
  }
};

export default Monthly;
