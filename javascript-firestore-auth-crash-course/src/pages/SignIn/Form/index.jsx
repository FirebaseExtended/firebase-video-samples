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

import { useRef, useState } from 'preact/hooks'
import { EmailButton } from '@/components/Buttons'
import styles from './Form.module.css'

export function SignUpForm(props) {
  const { onSubmit } = props
  const formEl = useRef(null)
  const [errorHash, setErrorHash] = useState({
    first: null,
    last: null,
    email: null,
    password: null,
  })
  return (
    <form
      ref={formEl}
      method=""
      noValidate
      onSubmit={(submitEvent) => {
        submitEvent.preventDefault()
        const user = getUser(formEl)
        const { hasErrors, errors } = getErrors(user)
        hasErrors ? setErrorHash(errors) : onSubmit(user)
      }}
    >
      <div class={styles.signInForm}>
        <InputRow>
          <InputControl
            label="First"
            name="first"
            placeholder="Sparky"
            error={errorHash.first}
          />
          <InputControl
            label="Last"
            name="last"
            placeholder="McFirebase"
            error={errorHash.last}
          />
        </InputRow>
        <InputRow>
          <InputControl
            label="Email"
            name="email"
            type="email"
            placeholder="sparkythebest@firebase.com"
            error={errorHash.email}
          />
        </InputRow>
        <InputRow>
          <InputControl
            label="Password"
            name="password"
            type="password"
            error={errorHash.password}
          />
        </InputRow>
        <InputRow>
          <EmailButton />
        </InputRow>
      </div>
    </form>
  )
}

export function SignInForm(props) {
  const { onSubmit } = props
  const formEl = useRef(null)
  const [errorHash, setErrorHash] = useState({
    first: null,
    last: null,
    email: null,
    password: null,
  })
  return (
    <form
      ref={formEl}
      method=""
      noValidate
      onSubmit={(submitEvent) => {
        submitEvent.preventDefault()
        const user = getUser(formEl)
        const { hasErrors, errors } = getErrors(user)
        hasErrors ? setErrorHash(errors) : onSubmit(user)
      }}
    >
      <div class={styles.signInForm}>
        <InputRow>
          <InputControl
            label="Email"
            name="email"
            type="email"
            placeholder="sparkythebest@firebase.com"
            error={errorHash.email}
          />
        </InputRow>
        <InputRow>
          <InputControl
            label="Password"
            name="password"
            type="password"
            error={errorHash.password}
          />
        </InputRow>
        <InputRow>
          <EmailButton />
        </InputRow>
      </div>
    </form>
  )
}

export function InputRow(props) {
  const { children } = props
  return <div class={styles.inputRow}>{children}</div>
}

export function InputControl(props) {
  const { label, name, value, placeholder, type, error } = props
  const hasError = error != null
  const errorCmp = hasError ? <InputError message={error} /> : null
  const controlClass = hasError ? styles.inputControlError : styles.inputControl
  return (
    <div class={controlClass}>
      <label htmlFor={name}>{label}</label>
      <input
        name={name}
        type={type || 'text'}
        placeholder={placeholder || ''}
        value={value}
      />
      {errorCmp}
    </div>
  )
}

export function InputError(props) {
  const { message } = props
  return (
    <div class={styles.inputError}>
      <p>{message}</p>
    </div>
  )
}

function getErrors(user) {
  let errors = {}
  let hasErrors = false
  const regex = {
    email: /^\S+@\S+\.\S+$/,
    password: /^(?=.*\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z]{8,}$/
  };
  Object.keys(user).forEach((key) => {
    const prop = user[key]
    if (prop == '') {
      errors[key] = "Can't be empty"
      hasErrors = true
    }
    if (key === 'email') {
      if (!regex.email.test(prop)) {
        errors[key] = 'Enter a valid email'
      }
    }
    if(key === 'password') {
      if(!regex.password.test(prop)) {
        errors[key] = 'Password must contain 8 characters, 1 uppercase, 1 lowercase, and 1 number'
      }
    }
  })
  return { hasErrors, errors }
}

function getUser(formEl) {
  const form = new FormData(formEl.current)
  return {
    first: form.get('first'),
    last: form.get('last'),
    email: form.get('email'),
    password: form.get('password'),
  }
  return user
}
