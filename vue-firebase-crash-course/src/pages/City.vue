<template>
  <Container v-if="city">
    <h1><span class="accent">{{ city.name }}</span>, {{ city.country }}</h1>
    <h3>Population: {{ city.population.toLocaleString() }}</h3>
  </Container>
</template>

<script setup>
import Container from '../components/Container.vue'
import { useCity } from '../cities'

const city = useCity(route => route.params.id)
</script>
