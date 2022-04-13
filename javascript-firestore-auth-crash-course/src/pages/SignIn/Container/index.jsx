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

import styles from './Container.module.css'

export function SignInContainer(props) {
  const { children, header } = props
  return (
    <div class={styles.signInContainer}>
      <main>
        <header class={styles.signInHeader}>
          <h4>{header}</h4>
        </header>
        <div>
          {children}
        </div>
      </main>
    </div>
  )
}

export function Heading(props) {
  return (
    <header class={styles.signInHeader}>
      <h4>{props.children}</h4>
    </header>
  )
}
