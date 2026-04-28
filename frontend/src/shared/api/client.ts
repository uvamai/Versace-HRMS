/// <reference types="vite/client" />
import axios from 'axios'

export const apiClient = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '',
  timeout: 30000,
  headers: { 'Content-Type': 'application/json' },
})

// Restore token on startup
const token = localStorage.getItem('access_token')
if (token) {
  apiClient.defaults.headers.common['Authorization'] = `Bearer ${token}`
}

// Response interceptor — handle 401 globally
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('access_token')
      localStorage.removeItem('refresh_token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// Generic helpers
export const api = {
  get: <T>(url: string, params?: Record<string, unknown>) =>
    apiClient.get<T>(url, { params }).then(r => r.data),

  post: <T>(url: string, data?: unknown) =>
    apiClient.post<T>(url, data).then(r => r.data),

  put: <T>(url: string, data?: unknown) =>
    apiClient.put<T>(url, data).then(r => r.data),

  patch: <T>(url: string, data?: unknown) =>
    apiClient.patch<T>(url, data).then(r => r.data),

  delete: <T>(url: string) =>
    apiClient.delete<T>(url).then(r => r.data),
}
