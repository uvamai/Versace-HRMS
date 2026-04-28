<template>
  <div class="page">
    <div class="page-header">
      <div>
        <h1>{{ isEdit ? 'Edit Employee' : 'New Employee' }}</h1>
        <p>{{ isEdit ? 'Update the employee profile.' : 'Create a new employee record.' }}</p>
      </div>
      <router-link class="secondary-button" :to="{ name: 'Employees' }">Back to list</router-link>
    </div>

    <form class="form-card" @submit.prevent="submit">
      <div class="field-grid">
        <label>
          Employee number
          <input v-model="form.employee_number" required />
        </label>
        <label>
          First name
          <input v-model="form.first_name" required />
        </label>
        <label>
          Last name
          <input v-model="form.last_name" required />
        </label>
        <label>
          Work email
          <input v-model="form.work_email" type="email" required />
        </label>
        <label>
          Date of joining
          <input v-model="form.date_of_joining" type="date" required />
        </label>
        <label>
          Phone
          <input v-model="form.mobile_phone" type="tel" />
        </label>
      </div>

      <div class="form-actions">
        <button type="submit" :disabled="saving">
          {{ saving ? 'Saving…' : isEdit ? 'Update employee' : 'Create employee' }}
        </button>
      </div>
      <p v-if="message" class="message">{{ message }}</p>
      <p v-if="error" class="error">{{ error }}</p>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { employeeApi, EmployeeCreatePayload } from '@/shared/api/employees'

const route = useRoute()
const router = useRouter()
const isEdit = route.name === 'EmployeeEdit'
const employeeId = route.params.id as string | undefined

const form = reactive<EmployeeCreatePayload>({
  employee_number: '',
  first_name: '',
  last_name: '',
  work_email: '',
  date_of_joining: '',
  mobile_phone: '',
})

const saving = ref(false)
const message = ref<string | null>(null)
const error = ref<string | null>(null)

async function loadEmployee() {
  if (!isEdit || !employeeId) return

  try {
    const employee = await employeeApi.get(employeeId)
    form.employee_number = employee.employee_number
    form.first_name = employee.first_name
    form.last_name = employee.last_name
    form.work_email = employee.work_email
    form.date_of_joining = employee.date_of_joining
    form.mobile_phone = employee.mobile_phone ?? ''
  } catch {
    error.value = 'Unable to load employee for editing.'
  }
}

async function submit() {
  saving.value = true
  error.value = null
  message.value = null

  try {
    if (isEdit && employeeId) {
      await employeeApi.update(employeeId, form)
      message.value = 'Employee updated successfully.'
    } else {
      const result = await employeeApi.create(form)
      message.value = 'Employee created successfully.'
      router.push({ name: 'EmployeeDetail', params: { id: result.id } })
    }
  } catch {
    error.value = 'Unable to save employee. Please check the form and try again.'
  } finally {
    saving.value = false
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

.form-card {
  background: white;
  padding: 1.5rem;
  border-radius: 1rem;
  box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
}

.field-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1rem;
}

label {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 1px solid #cbd5e1;
  border-radius: 0.75rem;
}

.form-actions {
  margin-top: 1.5rem;
}

button {
  padding: 0.85rem 1.25rem;
  border: none;
  border-radius: 0.75rem;
  background: #2563eb;
  color: white;
  cursor: pointer;
}

button:disabled {
  opacity: 0.65;
  cursor: not-allowed;
}

.message {
  margin-top: 1rem;
  color: #16a34a;
}

.error {
  margin-top: 1rem;
  color: #dc2626;
}
</style>
