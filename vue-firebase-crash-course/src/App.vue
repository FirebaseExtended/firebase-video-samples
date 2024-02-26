<template>
  <main>
    <router-view></router-view>
  </main>
</template>

<style scoped>
  main {
    position: relative;
    height: 100%;
  }
  .shape-l, .shape-r {
    position: absolute;
    width: 0;
    height: 0;
    border-style: solid;
    pointer-events: none;
  }
  .shape-r {
    bottom: 0;
    right: 0;
    border-width: 0 0 28vw 28vw;
    border-color: transparent transparent var(--theme-container) transparent;
  }
  .shape-l {
    top: 0;
    left: 0;
    border-width: 28vw 28vw 0 0;
    border-color: var(--theme-container) transparent transparent transparent;
  }
</style>