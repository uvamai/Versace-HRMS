<template>
  <div class="login-page">
    <div class="login-card">
      <h1>Sign in</h1>
      <form @submit.prevent="submit">
        <label>
          Email
          <input v-model="email" type="email" placeholder="name@company.com" required />
        </label>
        <label>
          Password
          <input v-model="password" type="password" placeholder="••••••••" required />
        </label>
        <button type="submit" :disabled="loading">
          {{ loading ? 'Signing in…' : 'Sign in' }}
        </button>
      </form>
      <p v-if="error" class="error-message">{{ error }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/shared/stores/auth'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const email = ref('')
const password = ref('')
const error = ref<string | null>(null)
const loading = ref(false)

async function submit() {
  error.value = null
  loading.value = true
  try {
    await auth.login(email.value, password.value)
    const target = (route.query.redirect as string) || '/dashboard'
    await router.replace(target)
  } catch (err) {
    error.value = 'Unable to sign in. Please check your credentials.'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: grid;
  place-items: center;
  background: #0f172a;
  color: white;
}

.login-card {
  width: min(420px, 100%);
  padding: 2rem;
  border-radius: 16px;
  background: rgba(15, 23, 42, 0.95);
  box-shadow: 0 24px 80px rgba(0, 0, 0, 0.2);
}

.login-card h1 {
  margin-bottom: 1.5rem;
}

label {
  display: block;
  margin-bottom: 1rem;
}

input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid #334155;
  border-radius: 0.75rem;
  background: #111827;
  color: white;
  margin-top: 0.5rem;
}

button {
  width: 100%;
  padding: 0.9rem;
  border: none;
  border-radius: 0.75rem;
  background: #2563eb;
  color: white;
  cursor: pointer;
  font-weight: 600;
}

button:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.error-message {
  margin-top: 1rem;
  color: #f87171;
}
</style>
