-- ============================================================
-- Versace HRMS — PostgreSQL Initialisation Script
-- Runs once when the container is first created
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";   -- for fuzzy search

-- ============================================================
-- Core lookup tables (shared across the system)
-- ============================================================

CREATE TABLE IF NOT EXISTS employment_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS employee_grades (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    default_salary_structure_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    parent_id UUID REFERENCES departments(id),
    head_employee_id UUID,            -- FK added after employees table
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS designations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL UNIQUE,
    department_id UUID REFERENCES departments(id),
    grade_id UUID REFERENCES employee_grades(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Employees (core entity)
-- ============================================================

CREATE TABLE IF NOT EXISTS employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Identity
    employee_number VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    last_name VARCHAR(100) NOT NULL,
    preferred_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    nationality VARCHAR(100),

    -- Contact
    personal_email VARCHAR(255) UNIQUE,
    work_email VARCHAR(255) UNIQUE NOT NULL,
    mobile_phone VARCHAR(30),
    work_phone VARCHAR(30),

    -- Employment
    employment_type_id UUID REFERENCES employment_types(id),
    department_id UUID REFERENCES departments(id),
    designation_id UUID REFERENCES designations(id),
    grade_id UUID REFERENCES employee_grades(id),
    reports_to_id UUID REFERENCES employees(id),
    date_of_joining DATE NOT NULL,
    date_of_leaving DATE,
    confirmation_date DATE,
    notice_period_days INTEGER DEFAULT 30,

    -- Status
    status VARCHAR(50) DEFAULT 'Active'
        CHECK (status IN ('Active', 'Inactive', 'On Leave', 'Terminated', 'Resigned')),

    -- Auth (links to users table)
    user_id UUID UNIQUE,

    -- Address
    current_address JSONB,            -- {street, city, state, country, postal_code}
    permanent_address JSONB,

    -- Emergency contact
    emergency_contact JSONB,          -- {name, relationship, phone}

    -- Bank details (encrypted in app layer)
    bank_details JSONB,

    -- Metadata
    profile_photo_url TEXT,
    created_by UUID,
    updated_by UUID,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ            -- soft delete
);

-- Add the FK now that employees table exists
ALTER TABLE departments
    ADD CONSTRAINT fk_dept_head
    FOREIGN KEY (head_employee_id) REFERENCES employees(id)
    DEFERRABLE INITIALLY DEFERRED;

-- ============================================================
-- Auth / Users
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,   -- HR_ADMIN, MANAGER, EMPLOYEE, PAYROLL_OFFICER, RECRUITER
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Leave Management
-- ============================================================

CREATE TABLE IF NOT EXISTS leave_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_carry_forward BOOLEAN DEFAULT false,
    max_carry_forward_days INTEGER,
    is_encashable BOOLEAN DEFAULT false,
    is_earned_leave BOOLEAN DEFAULT false,
    earned_leave_frequency VARCHAR(20),   -- monthly | quarterly
    max_days_allowed INTEGER,
    allow_half_day BOOLEAN DEFAULT true,
    requires_proof BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS leave_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS leave_policy_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_id UUID REFERENCES leave_policies(id) ON DELETE CASCADE,
    leave_type_id UUID REFERENCES leave_types(id),
    annual_allocation DECIMAL(5,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS leave_allocations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID REFERENCES employees(id),
    leave_type_id UUID REFERENCES leave_types(id),
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    total_days DECIMAL(5,2) NOT NULL,
    used_days DECIMAL(5,2) DEFAULT 0,
    carried_forward_days DECIMAL(5,2) DEFAULT 0,
    status VARCHAR(50) DEFAULT 'Active'
        CHECK (status IN ('Active', 'Expired', 'Cancelled')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS leave_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID REFERENCES employees(id),
    leave_type_id UUID REFERENCES leave_types(id),
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    is_half_day BOOLEAN DEFAULT false,
    half_day_date DATE,
    half_day_session VARCHAR(10),         -- Morning | Afternoon
    total_days DECIMAL(5,2) NOT NULL,
    reason TEXT,
    status VARCHAR(50) DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    approved_by UUID REFERENCES employees(id),
    approved_at TIMESTAMPTZ,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Attendance
-- ============================================================

CREATE TABLE IF NOT EXISTS shift_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    late_entry_grace_minutes INTEGER DEFAULT 0,
    early_exit_grace_minutes INTEGER DEFAULT 0,
    auto_attendance BOOLEAN DEFAULT false,
    working_hours DECIMAL(4,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS employee_checkins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID REFERENCES employees(id),
    log_type VARCHAR(10) NOT NULL CHECK (log_type IN ('IN', 'OUT')),
    timestamp TIMESTAMPTZ NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    location_name TEXT,
    device_id TEXT,
    skip_auto_attendance BOOLEAN DEFAULT false,
    shift_type_id UUID REFERENCES shift_types(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID REFERENCES employees(id),
    attendance_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL
        CHECK (status IN ('Present', 'Absent', 'Half Day', 'On Leave', 'Holiday', 'Work From Home')),
    shift_type_id UUID REFERENCES shift_types(id),
    check_in TIMESTAMPTZ,
    check_out TIMESTAMPTZ,
    working_hours DECIMAL(5,2),
    overtime_hours DECIMAL(5,2) DEFAULT 0,
    leave_application_id UUID REFERENCES leave_applications(id),
    is_late BOOLEAN DEFAULT false,
    is_early_exit BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (employee_id, attendance_date)
);

-- ============================================================
-- Audit Log (append-only)
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    employee_id UUID REFERENCES employees(id),
    action VARCHAR(50) NOT NULL,         -- CREATE | UPDATE | DELETE | LOGIN | APPROVE | REJECT
    resource_type VARCHAR(100) NOT NULL, -- employees | leave_applications | etc.
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- Indexes
-- ============================================================

CREATE INDEX idx_employees_status ON employees(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_work_email ON employees(work_email);
CREATE INDEX idx_leave_applications_employee ON leave_applications(employee_id);
CREATE INDEX idx_leave_applications_status ON leave_applications(status);
CREATE INDEX idx_attendance_employee_date ON attendance_records(employee_id, attendance_date);
CREATE INDEX idx_checkins_employee_time ON employee_checkins(employee_id, timestamp);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id, created_at);
CREATE INDEX idx_users_email ON users(email);

-- ============================================================
-- Seed default roles
-- ============================================================

INSERT INTO roles (name, description) VALUES
    ('SUPER_ADMIN', 'Full system access'),
    ('HR_ADMIN', 'HR operations and configuration'),
    ('PAYROLL_OFFICER', 'Payroll processing and salary management'),
    ('MANAGER', 'Team management, approvals'),
    ('RECRUITER', 'Recruitment pipeline management'),
    ('EMPLOYEE', 'Self-service access')
ON CONFLICT (name) DO NOTHING;

INSERT INTO employment_types (name) VALUES
    ('Full-Time'), ('Part-Time'), ('Contract'), ('Intern'), ('Casual')
ON CONFLICT (name) DO NOTHING;
