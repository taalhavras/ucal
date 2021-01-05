import React, { Component } from 'react';
import moment from "moment"
import { BrowserRouter, Route , Switch, Link } from "react-router-dom";
import _ from 'lodash';
import HeaderBar from "./lib/header-bar.js"

import styled, { ThemeProvider, createGlobalStyle } from 'styled-components';

import light from './themes/light';
import dark from './themes/dark';

import { Text, Box } from '@tlon/indigo-react';

import Daily from './daily';
import Monthly from './monthly';

import { store } from '../store';


export class Root extends Component {
  constructor(props) {
    super(props);
    this.store = store;
    this.store.setStateHandler(this.setState.bind(this));
    this.state = store.state;
    this.updateTheme = this.updateTheme.bind(this);
  }

  updateTheme(updateTheme) {
    this.setState({ dark: updateTheme });
  }

  componentDidMount() {
    this.themeWatcher = window.matchMedia('(prefers-color-scheme: dark)');
    this.setState({ dark: this.themeWatcher.matches });
    this.themeWatcher.addListener(this.updateTheme);
  }

  render() {
    const props = this.props;
    const state = this.state;

    return (
      <BrowserRouter>
        <ThemeProvider theme={this.state.dark ? dark : light}>
        <Box display='flex' flexDirection='column' position='absolute' backgroundColor='white' height='100%' width='100%' px={[0,4]} pb={[0,4]}>
        <HeaderBar/>
        <Switch>
        <Route exact path="/~ucal" render={ () => {
          const today = moment().startOf("day");
          const tomorrow = moment(today).add(1, 'day').format('~YYYY.M.D');
          const yesterday = moment(today).subtract(1, 'day').format('~YYYY.M.D');
          return (
            <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
              <Text fontSize='1'>ucal</Text>
              <Text pt='3'>Welcome to your Landscape application.</Text>
              <Text pt='3'>To get started, edit <code>src/index.js</code> or <code>urbit/app/ucal.hoon</code> and <code>|commit %home</code> on your Urbit ship to see your changes.</Text>
              <Link className="db f8 pt3" to="/~ucal/today">-> See today</Link>
              <Link className="db f8 pt3" to="/~ucal/monthly">-> See the monthly view</Link>
              <Link className="db f8 pt3" to={`/~ucal/day/${yesterday}`}>-> See {yesterday}</Link>
              <Link className="db f8 pt3" to={`/~ucal/day/${tomorrow}`}>-> See {tomorrow}</Link>
              <Daily {...props} {...state} day={today.format()} />
            </Box>
          )}}
        />
        <Route path="/~ucal/today" render={ () => {
          const today = moment().startOf("day");
          const tomorrow = moment(today).add(1, 'day').format('~YYYY.M.D');
          const yesterday = moment(today).subtract(1, 'day').format('~YYYY.M.D');
          return (
            <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
              <Text fontSize='1'>ucal</Text>
              <Link className="db f8 pt3" to="/~ucal/today">-> See today</Link>
              <Link className="db f8 pt3" to="/~ucal/monthly">-> See the monthly view</Link>
              <Link className="db f8 pt3" to={`/~ucal/day/${yesterday}`}>-> See {yesterday}</Link>
              <Link className="db f8 pt3" to={`/~ucal/day/${tomorrow}`}>-> See {tomorrow}</Link>
              <Daily {...props} {...state} day={today.format()} />
            </Box>
          )}}
        />
        <Route path="/~ucal/day/:day" render={ (routeProps) => {
          const { day } = routeProps.match.params;

          const today = moment(day, '~YYYY.M.D').startOf("day");
          const tomorrow = moment(today).add(1, 'day').format('~YYYY.M.D');
          const yesterday = moment(today).subtract(1, 'day').format('~YYYY.M.D');

          return (
            <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
              <Text fontSize='1'>ucal</Text>
              <Link className="db f8 pt3" to="/~ucal/today">-> See today</Link>
              <Link className="db f8 pt3" to="/~ucal/monthly">-> See the monthly view</Link>
              <Link className="db f8 pt3" to={`/~ucal/day/${yesterday}`}>-> See {yesterday}</Link>
              <Link className="db f8 pt3" to={`/~ucal/day/${tomorrow}`}>-> See {tomorrow}</Link>
              <Daily {...props} {...state} day={today.format()} />
            </Box>
          )}}
        />
        <Route path="/~ucal/monthly" render={ () => {
          return (
            <Box height='100%' p='4' display='flex' flexDirection='column' borderWidth={['none', '1px']} borderStyle="solid" borderColor="washedGray">
              <Text fontSize='1'>ucal</Text>
              <Link className="db f8 pt3" to="/~ucal/today">-> See today</Link>
              <Link className="db f8 pt3" to="/~ucal/monthly">-> See the monthly view</Link>
              <Monthly {...props} {...state} />
            </Box>
          )}}
        />
        </Switch>
        </Box>
        </ThemeProvider>
      </BrowserRouter>
    )
  }
}

