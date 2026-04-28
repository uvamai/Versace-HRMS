import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/shared/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    // Auth
    { path: '/login',    name: 'Login',    component: () => import('@/modules/auth/LoginView.vue'),    meta: { public: true } },
    { path: '/logout',   name: 'Logout',   component: () => import('@/modules/auth/LogoutView.vue'),   meta: { public: true } },

    // App shell (requires auth)
    {
      path: '/',
      component: () => import('@/shared/components/layout/AppShell.vue'),
      meta: { requiresAuth: true },
      children: [
        { path: '',          redirect: '/dashboard' },
        { path: 'dashboard', name: 'Dashboard',  component: () => import('@/modules/dashboard/DashboardView.vue') },

        // Employees
        { path: 'employees',          name: 'Employees',       component: () => import('@/modules/employees/EmployeeListView.vue') },
        { path: 'employees/new',      name: 'EmployeeNew',     component: () => import('@/modules/employees/EmployeeFormView.vue'), meta: { requiresHRAdmin: true } },
        { path: 'employees/:id',      name: 'EmployeeDetail',  component: () => import('@/modules/employees/EmployeeDetailView.vue') },
        { path: 'employees/:id/edit', name: 'EmployeeEdit',    component: () => import('@/modules/employees/EmployeeFormView.vue'), meta: { requiresHRAdmin: true } },

        // Leave
        { path: 'leave',              name: 'Leave',           component: () => import('@/modules/leave/LeaveListView.vue') },
        { path: 'leave/apply',        name: 'LeaveApply',      component: () => import('@/modules/leave/LeaveApplyView.vue') },
        { path: 'leave/approvals',    name: 'LeaveApprovals',  component: () => import('@/modules/leave/LeaveApprovalsView.vue') },

        // Attendance
        { path: 'attendance',         name: 'Attendance',      component: () => import('@/modules/attendance/AttendanceView.vue') },
        { path: 'attendance/checkin', name: 'CheckIn',         component: () => import('@/modules/attendance/CheckInView.vue') },
      ]
    },

    // 404
    { path: '/:pathMatch(.*)*', name: 'NotFound', component: () => import('@/shared/components/ui/NotFoundView.vue') },
  ]
})

// Navigation guard — redirect to login if not authenticated
router.beforeEach(async (to) => {
  const auth = useAuthStore()

  if (to.meta.public) return true

  if (!auth.isAuthenticated) {
    await auth.restoreSession()
  }

  if (!auth.isAuthenticated) {
    return { name: 'Login', query: { redirect: to.fullPath } }
  }

  if (to.meta.requiresHRAdmin && !auth.isHRAdmin) {
    return { name: 'Employees' }
  }

  return true
})

export default router
