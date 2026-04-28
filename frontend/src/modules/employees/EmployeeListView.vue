<template>
  <div class="page shell-page">
    <div class="page-header">
      <div>
        <h1>Employees</h1>
        <p>View and manage employee records for your organization.</p>
      </div>
      <router-link v-if="auth.isHRAdmin" class="primary-button" :to="{ name: 'EmployeeNew' }">New Employee</router-link>
    </div>

    <div class="toolbar">
      <input
        v-model="search"
        placeholder="Search by name, email, or employee number"
        @keyup.enter="loadEmployees"
      />
      <select v-model="statusFilter" @change="loadEmployees">
        <option value="">All statuses</option>
        <option value="Active">Active</option>
        <option value="Onboarding">Onboarding</option>
        <option value="Terminated">Terminated</option>
      </select>
      <button @click="resetFilters">Reset</button>
    </div>

    <div v-if="loading" class="status">Loading employees…</div>
    <div v-else-if="error" class="status error">{{ error }}</div>
    <div v-else>
      <table class="employee-table">
        <thead>
          <tr>
            <th>Employee #</th>
            <th>Name</th>
            <th>Email</th>
            <th>Status</th>
            <th>Joined</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="employee in employees" :key="employee.id">
            <td>{{ employee.employee_number }}</td>
            <td>
              <router-link :to="{ name: 'EmployeeDetail', params: { id: employee.id } }">
                {{ employee.full_name }}
              </router-link>
            </td>
            <td>{{ employee.work_email }}</td>
            <td>{{ employee.status }}</td>
            <td>{{ employee.date_of_joining }}</td>
          </tr>
        </tbody>
      </table>

      <div class="pagination" v-if="meta.pages > 1">
        <button @click="loadPage(page - 1)" :disabled="page <= 1">Previous</button>
        <span>Page {{ page }} of {{ meta.pages }}</span>
        <button @click="loadPage(page + 1)" :disabled="page >= meta.pages">Next</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/shared/stores/auth'
import { employeeApi, EmployeeResponse, PaginatedEmployees } from '@/shared/api/employees'

const auth = useAuthStore()
const employees = ref<EmployeeResponse[]>([])
const loading = ref(false)
const error = ref<string | null>(null)
const page = ref(1)
const size = ref(20)
const search = ref('')
const statusFilter = ref('')
const meta = ref<PaginatedEmployees>({ items: [], total: 0, page: 1, size: 20, pages: 1 })

async function loadEmployees() {
  loading.value = true
  error.value = null

  try {
    const result = await employeeApi.list(page.value, size.value, search.value, statusFilter.value)
    employees.value = result.items
    meta.value = result
  } catch (err) {
    error.value = 'Unable to load employees. Please try again.'
  } finally {
    loading.value = false
  }
}

function resetFilters() {
  search.value = ''
  statusFilter.value = ''
  page.value = 1
  loadEmployees()
}

function loadPage(nextPage: number) {
  if (nextPage < 1 || nextPage > meta.value.pages) return
  page.value = nextPage
  loadEmployees()
}

onMounted(loadEmployees)
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

.primary-button {
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  background: #2563eb;
  color: white;
  text-decoration: none;
}

.employee-table {
  width: 100%;
  border-collapse: collapse;
}

.employee-table th,
.employee-table td {
  padding: 0.75rem 1rem;
  border-bottom: 1px solid #e2e8f0;
}

.toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.toolbar input,
.toolbar select {
  padding: 0.75rem 1rem;
  border: 1px solid #cbd5e1;
  border-radius: 0.75rem;
  min-width: 240px;
}

.toolbar button {
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  background: #0f172a;
  color: white;
  border: none;
  cursor: pointer;
}

.employee-table th {
  text-align: left;
  background: #f8fafc;
}

.pagination {
  margin-top: 1rem;
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 0.75rem;
}

.status {
  padding: 1rem;
  color: #334155;
}

.error {
  color: #dc2626;
}
</style>
