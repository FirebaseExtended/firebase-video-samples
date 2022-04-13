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

import { useRef, useEffect } from 'preact/hooks'
import styles from '../ChatBox.module.css'

export function ChatInput(props) {
  const { onEnter } = props
  return (
    <div class={styles.inputContainer}>
      <input
        type="text"
        placeholder="Type your message here to get started..."
        onKeyUp={(keyEvent) => {
          if (keyEvent.key === 'Enter') {
            onEnter(keyEvent.target.value)
            keyEvent.target.value = ''
          }
        }}
      />
    </div>
  )
}

export function ChatContainer(props) {
  const { children } = props
  return <div class={styles.container}>{children}</div>
}

export function ChatList(props) {
  const { messages, user } = props
  const listEl = useRef(null)
  useEffect(() => {
    const scrollHeight = listEl.current.scrollHeight
    listEl.current.scroll(0, scrollHeight)
  }, [messages.length])
  return (
    <div class={styles.scrollContainer}>
      <ul class={styles.chatList} ref={listEl}>
        {messages.map((message) => {  
          return <ChatMessage key={message.id} message={message} />
        })}
      </ul>
    </div>
  )
}

export function ChatMessage(props) {
  const { message } = props
  let { id, text, role, isDelivered } = message
  role = role == null ? 'other' : role;
  const capitalizedRole = role.replace(
    role.charAt(0),
    role.charAt(0).toUpperCase(),
  )
  const pendingClass = !isDelivered ? 'Pending' : ''
  const parentClass = styles[`messageContainer${capitalizedRole}`]
  const messageClass = styles[`message${capitalizedRole}${pendingClass}`]
  const deliveredClass = styles[`delivered${capitalizedRole}`];
  return (
    <li id={id} class={parentClass}>
      <div class={messageClass}>{text}</div>
      {<div class={deliveredClass}>{isDelivered ? "Delivered" : ""}</div>}
    </li>
  )
}
