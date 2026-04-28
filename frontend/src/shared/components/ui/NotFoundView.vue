<template>
  <div class="not-found">
    <h1>404 — Page not found</h1>
    <p>The page you are looking for does not exist.</p>
    <router-link to="/">Return home</router-link>
  </div>
</template>

<script setup lang="ts"></script>

<style scoped>
.not-found {
  max-width: 600px;
  margin: 4rem auto;
  text-align: center;
}
</style>
