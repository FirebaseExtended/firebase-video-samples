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

import { ContentGrid, MainContentRow, SubContentRow } from '../Content'

export function SupportDetails() {
  return (
    <ContentGrid>
      <MainContentRow heading="Chat with Support">
        <p>
          We are here for you! Our support team is ready to answer your
          questions during our business hours.
        </p>
      </MainContentRow>

      <SubContentRow heading="Business Hours">
        <p>We're open Monday through Friday, except on major holidays.</p>
        <ul>
          <li>Mon: 7 a.m. - 9 p.m. ET</li>
          <li>Tue: 7 a.m. - 9 p.m. ET</li>
          <li>Wed: 7 a.m. - 9 p.m. ET</li>
          <li>Thu: 7 a.m. - 8 p.m. ET</li>
          <li>Fri: 9 a.m. - 5 p.m. ET</li>
        </ul>
      </SubContentRow>

      <SubContentRow heading="Questions?">
        <p>
          Check out our list of <a href="#">Frequently Asked Questions</a> to
          see if the most common things other customers are asking about.
        </p>
      </SubContentRow>
    </ContentGrid>
  )
}
