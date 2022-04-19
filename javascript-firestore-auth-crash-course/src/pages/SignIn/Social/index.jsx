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

import { Divider } from '../Divider'
import { GoogleButton, TwitterButton } from '@/components/Buttons';
import styles from './Social.module.css'

export function SignInSocial(props) {
  const { onClick } = props
  return (
    <div class={styles.signInSocial}>
      <div class={styles.socialButtons}>
        <GoogleButton onClick={(event) => onClick(event, 'google')} />
        <TwitterButton onClick={(event) => onClick(event, 'twitter')} />
      </div>

      <Divider text="or" />
    </div>
  )
}
