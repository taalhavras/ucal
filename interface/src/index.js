import React from 'react';
import ReactDOM from 'react-dom';
import { App } from './App';

import './css/indigo-static.css';
import './css/fonts.css';
import './css/custom.css';

window.urb = new window.channel();

ReactDOM.render((
  <App />
), document.querySelectorAll("#root")[0]);
