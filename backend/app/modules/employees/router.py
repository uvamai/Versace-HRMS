"""
Employee router — CRUD endpoints.
"""
import uuid
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.modules.employees.models import Employee
from app.shared.dependencies import PaginationParams, get_current_user, require_hr_admin
from app.modules.auth.models import User
from pydantic import BaseModel, EmailStr
from datetime import date, datetime
from typing import Optional


# ── Inline schemas (will move to schemas.py) ──────────────────
class EmployeeCreateRequest(BaseModel):
    employee_number: str
    first_name: str
    last_name: str
    work_email: EmailStr
    date_of_joining: date
    department_id: Optional[uuid.UUID] = None
    designation_id: Optional[uuid.UUID] = None
    employment_type_id: Optional[uuid.UUID] = None
    reports_to_id: Optional[uuid.UUID] = None
    gender: Optional[str] = None
    mobile_phone: Optional[str] = None


class EmployeeResponse(BaseModel):
    id: uuid.UUID
    employee_number: str
    first_name: str
    last_name: str
    full_name: str
    work_email: str
    status: str
    date_of_joining: date
    created_at: datetime

    class Config:
        from_attributes = True


class PaginatedResponse(BaseModel):
    items: list[EmployeeResponse]
    total: int
    page: int
    size: int
    pages: int


router = APIRouter()


@router.get("", response_model=PaginatedResponse)
async def list_employees(
    search: Optional[str] = Query(None),
    department_id: Optional[uuid.UUID] = Query(None),
    status: Optional[str] = Query(None),
    pagination: PaginationParams = Depends(),
    db: AsyncSession = Depends(get_db),
    _: User = Depends(get_current_user),
):
    """List employees with search, filter, and pagination."""
    query = select(Employee).where(Employee.deleted_at.is_(None))

    if search:
        query = query.where(
            (Employee.first_name.ilike(f"%{search}%")) |
            (Employee.last_name.ilike(f"%{search}%")) |
            (Employee.work_email.ilike(f"%{search}%")) |
            (Employee.employee_number.ilike(f"%{search}%"))
        )
    if department_id:
        query = query.where(Employee.department_id == department_id)
    if status:
        query = query.where(Employee.status == status)

    # Count total
    count_result = await db.execute(select(func.count()).select_from(query.subquery()))
    total = count_result.scalar_one()

    # Paginate
    result = await db.execute(query.offset(pagination.offset).limit(pagination.size))
    employees = result.scalars().all()

    return PaginatedResponse(
        items=[EmployeeResponse(
            id=e.id,
            employee_number=e.employee_number,
            first_name=e.first_name,
            last_name=e.last_name,
            full_name=e.full_name,
            work_email=e.work_email,
            status=e.status,
            date_of_joining=e.date_of_joining,
            created_at=e.created_at,
        ) for e in employees],
        total=total,
        page=pagination.page,
        size=pagination.size,
        pages=(total + pagination.size - 1) // pagination.size,
    )


@router.post("", response_model=EmployeeResponse, status_code=status.HTTP_201_CREATED)
async def create_employee(
    data: EmployeeCreateRequest,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_hr_admin),
):
    """Create a new employee. Requires HR_ADMIN role."""
    # Check uniqueness
    existing = await db.execute(
        select(Employee).where(
            (Employee.employee_number == data.employee_number) |
            (Employee.work_email == data.work_email)
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Employee number or email already exists")

    employee = Employee(**data.model_dump())
    db.add(employee)
    await db.flush()
    await db.refresh(employee)

    return EmployeeResponse(
        id=employee.id,
        employee_number=employee.employee_number,
        first_name=employee.first_name,
        last_name=employee.last_name,
        full_name=employee.full_name,
        work_email=employee.work_email,
        status=employee.status,
        date_of_joining=employee.date_of_joining,
        created_at=employee.created_at,
    )


@router.get("/{employee_id}", response_model=EmployeeResponse)
async def get_employee(
    employee_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(get_current_user),
):
    """Get employee by ID."""
    result = await db.execute(
        select(Employee).where(Employee.id == employee_id, Employee.deleted_at.is_(None))
    )
    employee = result.scalar_one_or_none()
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")

    return EmployeeResponse(
        id=employee.id,
        employee_number=employee.employee_number,
        first_name=employee.first_name,
        last_name=employee.last_name,
        full_name=employee.full_name,
        work_email=employee.work_email,
        status=employee.status,
        date_of_joining=employee.date_of_joining,
        created_at=employee.created_at,
    )


@router.delete("/{employee_id}", response_model=dict)
async def soft_delete_employee(
    employee_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(require_hr_admin),
):
    """Soft-delete an employee."""
    from datetime import timezone
    result = await db.execute(
        select(Employee).where(Employee.id == employee_id, Employee.deleted_at.is_(None))
    )
    employee = result.scalar_one_or_none()
    if not employee:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Employee not found")

    employee.deleted_at = datetime.now(timezone.utc)
    employee.status = "Terminated"
    await db.flush()
    return {"message": "Employee deleted successfully"}
