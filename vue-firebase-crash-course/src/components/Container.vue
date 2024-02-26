<template>
  <section>
    <slot />
  </section>
</template>

<style scoped>
  section {
    display: flex;
    flex-direction: column;
    justify-content: center;
    margin: 0px auto;
    width: 820px;
    padding-inline: 16px;
    gap: 16px;
    height: 100%;
  }
</style>
