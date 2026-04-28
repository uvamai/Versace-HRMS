<template>
  <div class="logout-screen">
    <p>Signing out...</p>
  </div>
</template>

<script setup lang="ts">
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/shared/stores/auth'

const auth = useAuthStore()
const router = useRouter()

onMounted(async () => {
  await auth.logout()
  router.replace({ name: 'Login' })
})
</script>

<style scoped>
.logout-screen {
  min-height: 100vh;
  display: grid;
  place-items: center;
  color: #334155;
}
</style>
