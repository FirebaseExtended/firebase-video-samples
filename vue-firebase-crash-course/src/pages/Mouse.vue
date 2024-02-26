<template>
  <main ref="main">
    <ul>
      <li>x - {{ coordinates.x }}</li>
      <li>y - {{ coordinates.y }}</li>
    </ul>
  </main>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useMouse } from '../mouse';
const coordinates = useMouse();
const main = ref(null)
main.value.style.setProperty('--text-glow', (coordinates.y / 20) + 'px')
</script>

<style scoped>
main {
  --text-glow: 0px;
  --really-green: oklch(88.14% 0.203 158.82);
  height: 100dvh;
  display: grid;
  place-items: center;
  place-content: center;
  text-align: center;
  font: var(--text-h2);
  gap: 12px;
  text-shadow: 0 0 var(--text-glow) var(--really-green);
}
</style>
