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

import { Component } from 'preact'
import { ChatContainer, ChatList, ChatInput } from './components';
import { streamMessages } from '../../../firebase';
export class ChatBox extends Component {

  componentDidMount() {
    const { caseId } = this.props;
    const { stream, addMessage } = streamMessages({ caseId });
    stream(messages => {
      const userId = this.props.user.uid;
      messages = messages.map(m => {
        const role = m.uid === userId ? 'self' : 'other';
        return { ...m, role };
      })
      this.props.setMessages(messages)
    })
    this.addMessage = addMessage;
  }

  render(props) {
    return (
      <ChatContainer>
        <ChatList messages={props.messages} />
        <ChatInput
          onEnter={(text) => {
            this.addMessage({ text, uid: props.user.uid })
          }}
        />
      </ChatContainer>
    )
  }
}
