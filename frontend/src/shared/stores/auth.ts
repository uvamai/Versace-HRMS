import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { apiClient } from '@/shared/api/client'

interface User {
  id: string
  email: string
  roles: string[]
  is_active: boolean
  last_login: string | null
}

interface Tokens {
  access_token: string
  refresh_token: string
  expires_in: number
}

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const accessToken = ref<string | null>(localStorage.getItem('access_token'))
  const refreshToken = ref<string | null>(localStorage.getItem('refresh_token'))
  const loading = ref(false)

  const isAuthenticated = computed(() => !!accessToken.value && !!user.value)
  const hasRole = (role: string) => user.value?.roles.includes(role) ?? false
  const isHRAdmin = computed(() => hasRole('HR_ADMIN') || hasRole('SUPER_ADMIN'))
  const isManager = computed(() => hasRole('MANAGER') || isHRAdmin.value)

  function setTokens(tokens: Tokens) {
    accessToken.value = tokens.access_token
    refreshToken.value = tokens.refresh_token
    localStorage.setItem('access_token', tokens.access_token)
    localStorage.setItem('refresh_token', tokens.refresh_token)
    apiClient.defaults.headers.common['Authorization'] = `Bearer ${tokens.access_token}`
  }

  function clearAuth() {
    user.value = null
    accessToken.value = null
    refreshToken.value = null
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    delete apiClient.defaults.headers.common['Authorization']
  }

  async function login(email: string, password: string) {
    loading.value = true
    try {
      const response = await apiClient.post('/api/v1/auth/login', { email, password })
      setTokens(response.data.tokens)
      user.value = response.data.user
      return response.data
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    try {
      if (refreshToken.value) {
        await apiClient.post('/api/v1/auth/logout', { refresh_token: refreshToken.value })
      }
    } catch { /* ignore */ }
    clearAuth()
  }

  async function restoreSession() {
    if (!accessToken.value) return

    apiClient.defaults.headers.common['Authorization'] = `Bearer ${accessToken.value}`
    try {
      const response = await apiClient.get('/api/v1/auth/me')
      user.value = response.data
    } catch {
      // Token expired — try refresh
      if (refreshToken.value) {
        try {
          const r = await apiClient.post('/api/v1/auth/refresh', { refresh_token: refreshToken.value })
          setTokens(r.data)
          const me = await apiClient.get('/api/v1/auth/me')
          user.value = me.data
        } catch {
          clearAuth()
        }
      } else {
        clearAuth()
      }
    }
  }

  return { user, accessToken, loading, isAuthenticated, isHRAdmin, isManager, hasRole, login, logout, restoreSession }
})
