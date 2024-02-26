<template>
  <Container>
    <h1>Are you supposed to be here?</h1>
    <h3>Probably not.</h3>
    <div>
      <button>
        <router-link :to="{ name: 'Auth' }">Authentication</router-link>
      </button>
    </div>
    <router-link :to="{ name: 'Home' }">Go to Home</router-link>
  </Container>
</template>

<script setup>
import Container from '../components/Container.vue';
</script>
