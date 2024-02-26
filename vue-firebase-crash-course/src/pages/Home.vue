<template>
  <Container>
    <h1>Vue + <span class="accent">Firebase</span>!</h1>
    <div>
      <button>
        <router-link :to="{ name: 'Auth' }">Let's go</router-link>
      </button>
    </div>
    <h3>There's a lot to learn.</h3>
    <ul class="gap-8">
      <li>
        <router-link :to="{ name: 'Auth'}">Authentication</router-link>
      </li>
      <li>
        <router-link :to="{ name: 'Protected'}">Protected Routes</router-link>
      </li>
      <li>
        <router-link :to="{ name: 'Firestore'}">Firestore</router-link>
      </li>
      <li>
        <router-link :to="{ name: 'City', params: { id: 'OSfT0M1s9rYUkZn0aVej'} }">Single Object Routes</router-link>
      </li>
    </ul>
  </Container>
</template>

<script setup>
import Container from '../components/Container.vue'
</script>
