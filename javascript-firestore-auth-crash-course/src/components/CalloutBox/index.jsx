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

import styles from './CalloutBox.module.css'

export function CalloutBox(props) {
  const {} = props
  return (
    <div class={styles.calloutBox}>
      <div class={styles.calloutContent}>
        <h5>&gt; We found an existing account</h5>
        <p>
          You attempted to sign in with Google, but we found an account with an
          existing email. If you want link a the accounts click the Link button
          below.
        </p>
      </div>

      <div class={styles.calloutButtons}>
        <button class="outlined">Learn More</button>
        <button>Link accounts</button>
      </div>
    </div>
  )
}
