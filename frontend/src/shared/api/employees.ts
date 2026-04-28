import { api } from './client'

export interface EmployeeCreatePayload {
  employee_number: string
  first_name: string
  last_name: string
  work_email: string
  date_of_joining: string
  department_id?: string
  designation_id?: string
  employment_type_id?: string
  reports_to_id?: string
  gender?: string
  mobile_phone?: string
}

export interface EmployeeResponse {
  id: string
  employee_number: string
  first_name: string
  last_name: string
  full_name: string
  work_email: string
  status: string
  date_of_joining: string
  department_id?: string
  designation_id?: string
  employment_type_id?: string
  reports_to_id?: string
  gender?: string
  mobile_phone?: string
  created_at: string
}

export interface PaginatedEmployees {
  items: EmployeeResponse[]
  total: number
  page: number
  size: number
  pages: number
}

export const employeeApi = {
  list: (page = 1, size = 20, search?: string, status?: string, department_id?: string) =>
    api.get<PaginatedEmployees>('/api/v1/employees', { page, size, search, status, department_id }),

  get: (id: string) => api.get<EmployeeResponse>(`/api/v1/employees/${id}`),

  create: (payload: EmployeeCreatePayload) => api.post<EmployeeResponse>('/api/v1/employees', payload),

  update: (id: string, payload: Partial<EmployeeCreatePayload>) =>
    api.patch<EmployeeResponse>(`/api/v1/employees/${id}`, payload),

  remove: (id: string) => api.delete<{ message: string }>(`/api/v1/employees/${id}`),
}
