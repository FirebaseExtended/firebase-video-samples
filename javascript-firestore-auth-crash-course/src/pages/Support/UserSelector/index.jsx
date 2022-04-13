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

import styles from './UserSelector.module.css';

export function UserSelector(props) {
  const { onSelected, selected } = props
  return (
    <div class={styles.userSelector}>
      <TypeRadio type="Agent" value="agent" onSelected={onSelected} checked={selected === 'agent'} />
      <TypeRadio type="Customer" value="customer" onSelected={onSelected} checked={selected === 'customer'} />
    </div>
  )
}

function TypeRadio(props) {
  const { type, value, onSelected, checked} = props;
  return (
    <div>
      <input checked={checked} type="radio" value={value} name="type" onClick={clickEvent => {
        onSelected(value);
      }} />
      <label for="agent">{type}</label>
    </div>
  )
}
