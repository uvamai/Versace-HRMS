<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1>Employee Details</h1>
        <p>View employee profile information and status.</p>
      </div>
      <router-link class="secondary-button" :to="{ name: 'Employees' }">Back to list</router-link>
    </div>

    <div v-if="loading" class="status">Loading employee…</div>
    <div v-else-if="error" class="status error">{{ error }}</div>
    <div v-else-if="employee" class="details-card">
      <div class="row">
        <div>
          <strong>Name</strong>
          <p>{{ employee.full_name }}</p>
        </div>
        <div>
          <strong>Employee #</strong>
          <p>{{ employee.employee_number }}</p>
        </div>
      </div>
      <div class="row">
        <div>
          <strong>Email</strong>
          <p>{{ employee.work_email }}</p>
        </div>
        <div>
          <strong>Status</strong>
          <p>{{ employee.status }}</p>
        </div>
      </div>
      <div class="row">
        <div>
          <strong>Joined</strong>
          <p>{{ employee.date_of_joining }}</p>
        </div>
        <div>
          <strong>Phone</strong>
          <p>{{ employee.mobile_phone || 'N/A' }}</p>
        </div>
      </div>
      <div class="detail-actions" v-if="auth.isHRAdmin">
        <router-link class="primary-button" :to="{ name: 'EmployeeEdit', params: { id: employee.id } }">Edit</router-link>
        <button class="danger-button" @click="confirmDelete" :disabled="deleting">{{ deleting ? 'Deleting…' : 'Delete' }}</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/shared/stores/auth'
import { employeeApi, EmployeeResponse } from '@/shared/api/employees'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()
const employee = ref<EmployeeResponse | null>(null)
const loading = ref(false)
const deleting = ref(false)
const error = ref<string | null>(null)

async function loadEmployee() {
  const id = route.params.id as string
  if (!id) {
    error.value = 'Missing employee id.'
    return
  }

  loading.value = true
  error.value = null

  try {
    employee.value = await employeeApi.get(id)
  } catch {
    error.value = 'Unable to load employee details. Please try again.'
  } finally {
    loading.value = false
  }
}

async function confirmDelete() {
  if (!employee.value || !confirm('Delete this employee? This action will soft-delete the record.')) {
    return
  }

  deleting.value = true
  error.value = null
  try {
    await employeeApi.remove(employee.value.id)
    router.push({ name: 'Employees' })
  } catch {
    error.value = 'Unable to delete employee. Please try again.'
  } finally {
    deleting.value = false
  }
}

onMounted(loadEmployee)
</script>

<style scoped>
.page {
  padding: 1rem;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.secondary-button {
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  background: #e2e8f0;
  color: #0f172a;
  text-decoration: none;
}

.detail-actions {
  margin-top: 1.5rem;
  display: flex;
  gap: 0.75rem;
}

.primary-button {
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  background: #2563eb;
  color: white;
  text-decoration: none;
}

.danger-button {
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  background: #dc2626;
  color: white;
  border: none;
  cursor: pointer;
}

.danger-button:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.details-card {
  background: white;
  border-radius: 1rem;
  padding: 1.5rem;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
}

.row {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.row strong {
  display: block;
  margin-bottom: 0.5rem;
  color: #0f172a;
}

.status {
  padding: 1rem;
  color: #334155;
}

.error {
  color: #dc2626;
}
</style>
