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

export function EmailButton(props) {
  const { onClick } = props
  return (
    <SocialButton
      text="Sign in with Email"
      onClick={onClick}
      svg={() => <EmaiLogo />}
    />
  )
}

export function GoogleButton(props) {
  const { onClick } = props
  return (
    <SocialButton
      text="Sign in with Google"
      onClick={onClick}
      svg={() => <GoogleLogo />}
    />
  )
}

export function TwitterButton(props) {
  const { onClick } = props
  return (
    <SocialButton
      text="Sign in with Twitter"
      onClick={onClick}
      svg={() => <TwitterLogo />}
    />
  )
}

export function SocialButton(props) {
  const { svg, text, onClick } = props
  return (
    <button class="icon" onClick={onClick}>
      {svg()}
      <span>{text}</span>
    </button>
  )
}

export function GoogleLogo() {
  return (
    <svg
      width="15"
      height="15"
      viewBox="0 0 15 15"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M1.60106 4.22266C2.08639 3.26153 2.7869 2.42531 3.64809 1.77904C4.50929 1.13277 5.50797 0.693883 6.56644 0.496508C7.62492 0.299133 8.71465 0.348593 9.75089 0.64104C10.7871 0.933488 11.7419 1.46104 12.5411 2.18266L10.5311 4.19266C9.81116 3.50293 8.84791 3.12553 7.85106 3.14266C6.97896 3.15497 6.13267 3.44041 5.43128 3.95883C4.72988 4.47725 4.2087 5.20255 3.94106 6.03266C3.65287 6.89591 3.65287 7.82941 3.94106 8.69266C4.14031 9.30619 4.47821 9.86559 4.92854 10.3275C5.37888 10.7893 5.92955 11.1412 6.53785 11.3559C7.14615 11.5706 7.79573 11.6423 8.4362 11.5655C9.07668 11.4886 9.69085 11.2652 10.2311 10.9127C10.5937 10.6713 10.9039 10.3591 11.1427 9.99473C11.3816 9.6304 11.5443 9.22151 11.6211 8.79266H7.85106V6.09266H14.4511C14.5311 6.54266 14.5711 7.02266 14.5711 7.52266C14.5711 9.65266 13.8111 11.4427 12.4811 12.6627C11.2111 13.7992 9.55475 14.4074 7.85106 14.3627C6.65665 14.3633 5.48193 14.0583 4.43869 13.4767C3.39545 12.8951 2.51838 12.0562 1.89093 11.0399C1.26349 10.0235 0.906542 8.86354 0.854053 7.67028C0.801565 6.47701 1.05528 5.29017 1.59106 4.22266H1.60106Z"
        fill="white"
      />
    </svg>
  )
}

export function TwitterLogo() {
  return (
    <svg
      width="17"
      height="14"
      viewBox="0 0 17 14"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M14.7154 4.13182C14.7251 4.27182 14.7251 4.41182 14.7251 4.55311C14.7251 8.85827 11.4477 13.8234 5.45476 13.8234V13.8208C3.68444 13.8234 1.95089 13.3163 0.460571 12.3602C0.717991 12.3912 0.9767 12.4067 1.23606 12.4073C2.70315 12.4086 4.12831 11.9163 5.28251 11.0099C3.88831 10.9834 2.66573 10.0744 2.23864 8.7473C2.72702 8.84149 3.23025 8.82214 3.7096 8.69117C2.1896 8.38407 1.09606 7.04859 1.09606 5.49762C1.09606 5.48343 1.09606 5.46988 1.09606 5.45633C1.54896 5.70859 2.05606 5.84859 2.57476 5.86407C1.14315 4.9073 0.701862 3.00278 1.56638 1.51375C3.22057 3.54923 5.66122 4.78665 8.28122 4.91762C8.01864 3.78601 8.37735 2.6002 9.2238 1.80472C10.5361 0.57117 12.5999 0.634396 13.8335 1.94601C14.5632 1.80214 15.2625 1.5344 15.9025 1.15504C15.6593 1.90923 15.1502 2.54988 14.4702 2.95698C15.1161 2.88085 15.747 2.70794 16.3412 2.44407C15.9038 3.09956 15.3528 3.67052 14.7154 4.13182Z"
        fill="white"
      />
    </svg>
  )
}

export function EmaiLogo() {
  return (
    <svg
      width="21"
      height="17"
      viewBox="0 0 21 17"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M18.3942 0.533691H2.39417C1.29417 0.533691 0.404165 1.43369 0.404165 2.53369L0.394165 14.5337C0.394165 15.6337 1.29417 16.5337 2.39417 16.5337H18.3942C19.4942 16.5337 20.3942 15.6337 20.3942 14.5337V2.53369C20.3942 1.43369 19.4942 0.533691 18.3942 0.533691ZM18.3942 14.5337H2.39417V4.53369L10.3942 9.53369L18.3942 4.53369V14.5337ZM10.3942 7.53369L2.39417 2.53369H18.3942L10.3942 7.53369Z"
        fill="#EDEBF3"
      />
    </svg>
  )
}
