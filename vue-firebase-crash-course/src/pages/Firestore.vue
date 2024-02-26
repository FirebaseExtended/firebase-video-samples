<template>
  <Container>
    <h1>VueFire <span class="accent">Firestore</span></h1>
    <router-link :to="{ name: 'Home' }">Go to Home</router-link>
    <h3>Filter by</h3>
    <div class="gap-8 button-list" v-if="lookup">
      <button v-for="name in lookup.names" @click="triggerChange">
        {{ name }}
      </button>
    </div>
    <ul class="gap-8 result-list">
      <li v-for="city in cities">
        <router-link :to="{ name: 'City', params: { id: city.id } }">
          {{ city.name }}, {{  city.country }}
        </router-link>
      </li>
    </ul>
  </Container>
</template>

<script setup>
import Container from '../components/Container.vue'
import { useCitiesQuery, useCityLookup } from '../cities'

const { cities, setQuery } = useCitiesQuery(route => [
  route.query.country && ['country', '==', route.query.country],
]);
const lookup = useCityLookup()

function triggerChange(clickEvent) {
  let country = clickEvent.target.textContent
  let query = { country }
  let whereList = ['country', '==', country];
  // Reset the Firestore Query
  if(clickEvent.target.nodeName !== 'BUTTON' || country === 'All Cities') {
    whereList = null
    delete query.country
  }
  setQuery({
    whereQuery: [whereList],
    onRoute: router => router.replace({ name: 'Firestore', query })
  })
}
</script>
