# Versace HRMS Roadmap

## Overview
This document tracks the current roadmap for Versace HRMS, including epics, tasks, and completion status. It is aligned to the PRD and the existing repository scaffold.

---

## Phase 1 — Foundation (Current Priority)
**Goal:** Establish the product foundation, local development flow, authentication, and core employee data.

### EPIC 1: Foundation & DevOps
- [x] Audit repo structure and existing modules
- [ ] Validate local Docker Compose development workflow
- [ ] Configure startup documentation for local development
- [ ] Add CI/CD stub and initial GitHub Actions plan
- [ ] Document environment variable requirements

### EPIC 2: Auth & Access Control
- [x] Implement JWT authentication on the backend
- [x] Add refresh token rotation and logout support
- [x] Build role-based access control (RBAC)
- [x] Seed default roles: `SUPER_ADMIN`, `HR_ADMIN`, `PAYROLL_OFFICER`, `MANAGER`, `RECRUITER`, `EMPLOYEE`
- [x] Add `/api/v1/auth/me` and authenticated user context
- [x] Create frontend login flow and protected route guard

### EPIC 3: Employee Management
- [x] Define employee lifecycle data model
- [x] Implement employee profile CRUD APIs
- [x] Support employee personal and organizational data
- [x] Add employee list and profile endpoints on frontend
- [ ] Add organization hierarchy and reporting structure support

### EPIC 4: Leave & Attendance Foundation
- [ ] Design leave type and leave policy models
- [ ] Implement leave application API with approval states
- [ ] Add basic attendance check-in/check-out API
- [ ] Ensure leave and attendance integration points are defined
- [ ] Add frontend forms for leave request and attendance punch

---

## Phase 2 — Core HR Modules (Planned)
**Goal:** Build out employee-facing self-service and manager workflows.

### EPIC 5: Leave Management
- [ ] Multiple leave types and accrual rules
- [ ] Leave balance tracking and calendar view
- [ ] Approval workflow for managers
- [ ] Holiday calendar support

### EPIC 6: Attendance Management
- [ ] Shift scheduling and assignments
- [ ] Overtime tracking and analytics
- [ ] Attendance reports and integrations
- [ ] Geolocation / location-aware check-in support

### EPIC 7: Org Structure & Reporting
- [ ] Define departments, teams, and reporting lines
- [ ] Add org chart visualization support
- [ ] Add manager and approval role mapping

---

## Phase 3 — Advanced Features (Planned)
**Goal:** Add payroll, performance, expense, and recruitment modules.

### EPIC 8: Performance Management
- [ ] Goal setting and KRAs
- [ ] Appraisal cycles and feedback
- [ ] 360-degree review support
- [ ] Performance analytics dashboard

### EPIC 9: Payroll Management
- [ ] Salary structure and components
- [ ] Payroll processing and tax calculations
- [ ] Payslip generation and delivery
- [ ] Deductions, benefits, and compliance reports

### EPIC 10: Expense & Recruitment
- [ ] Expense claim submission and approval
- [ ] Travel request and reimbursement workflows
- [ ] Job requisition and applicant tracking
- [ ] Interview scheduling and onboarding workflows

---

## Phase 4 — Integration & Testing (Planned)
- [ ] API documentation and OpenAPI validation
- [ ] Integration testing across backend and frontend
- [ ] Performance testing and benchmark validation
- [ ] Accessibility review and WCAG compliance
- [ ] Security review and audit logging

---

## Completion Tracker
1. **Repository audit and requirements review** — ✅ Completed
2. **Create roadmap and align epics to PRD** — ✅ Completed
3. **Begin Phase 1 work: Auth + RBAC foundation** — 🔄 In progress
4. **Next step: Validate Docker Compose dev stack and build login flow** — ⏳ Pending

---

## Current Sprint: Sprint 1
**Sprint focus:** Auth foundation, employee baseline, documentation.

- [x] Define and document Phase 1 epics and tasks
- [x] Verify backend auth module exists and supports login/refresh/logout
- [x] Verify current API router structure and add protected routes
- [x] Add frontend auth module skeleton
- [ ] Validate local stack using Docker Compose

---

## Notes
- This file is the single source of truth for current planning in the repository.
- Use task checkboxes to track completion as we progress.
- Update this file after each development milestone or after a new sprint is started.
