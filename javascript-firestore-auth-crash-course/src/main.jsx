/**
 * @license
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Router from 'preact-router';
import { Component, render } from 'preact'
import { Support } from '@/pages/Support'
import { SignIn, SignUp } from '@/pages/SignIn';
import { onAuth } from './firebase';
import './reset.css'
import './variables.css'
import './base.css'

export class App extends Component {

  constructor() {
    super()
    this.state = {
      user: null,
      messages: [],
    };
  }

  componentDidMount() {
    onAuth(user => {
      if(user != null) {
        this.setState({
          ...this.state,
          user,
        })
      } else {
        // redirect
      }
    });
  }

  render(props, state) {
    return (
      <Router>
        <Support {...state} path="/cases/:caseId?" setMessages={messages => {
          this.setState({
            ...state,
            messages,
          });
        }} />
        <SignIn path="/signin" />
        <SignUp path="/signup" />
      </Router>
    )
  }
}

render(<App />, document.getElementById('app'))
