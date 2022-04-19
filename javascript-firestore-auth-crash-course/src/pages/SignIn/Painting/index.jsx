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

import styles from './Painting.module.css'

export function Painting() {
  return (
    <div class={styles.painting}>
      <div class={styles.circleGroup}>
        <div class={styles.cornerLeft}>
          <SmallTriCircles />
        </div>

        <div class={styles.cornerRight}>
          <UnevenTriCricles />
        </div>

        <LargeCircles />
      </div>
    </div>
  )
}

export function SmallTriCircles() {
  return (
    <svg
      width="59"
      height="69"
      viewBox="0 0 59 69"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <circle
        opacity="0.2"
        cx="11.8049"
        cy="34.6083"
        r="11.4029"
        fill="#C8BAF1"
      />
      <circle
        opacity="0.2"
        cx="46.6794"
        cy="11.8025"
        r="11.4029"
        fill="#C8BAF1"
      />
      <circle
        opacity="0.2"
        cx="46.6794"
        cy="57.4141"
        r="11.4029"
        fill="#C8BAF1"
      />
    </svg>
  )
}

export function LargeCircles() {
  return (
    <svg
      width="587"
      height="100vh"
      viewBox="0 0 587 251"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <circle cx="460.896" cy="125.5" r="125.17" fill="currentColor" />
      <circle cx="375.566" cy="125.5" r="125.17" fill="currentColor" />
      <circle cx="250.397" cy="125.5" r="125.17" fill="currentColor" />
      <circle cx="125.227" cy="125.5" r="125.17" fill="currentColor" />
    </svg>
  )
}

export function UnevenTriCricles() {
  return (
    <svg
      width="68"
      height="70"
      viewBox="0 0 68 70"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <ellipse
        opacity="0.1"
        cx="18.8638"
        cy="17.6982"
        rx="17.9698"
        ry="17.1043"
        fill="#C8BAF1"
      />
      <ellipse
        opacity="0.3"
        cx="55.2673"
        cy="46.378"
        rx="12.4552"
        ry="11.5755"
        fill="#C8BAF1"
      />
      <ellipse
        opacity="0.2"
        cx="13.3493"
        cy="57.9536"
        rx="12.4552"
        ry="11.5755"
        fill="#C8BAF1"
      />
    </svg>
  )
}
