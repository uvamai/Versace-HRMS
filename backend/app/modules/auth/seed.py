"""Seed initial authentication data and roles."""
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.modules.auth.models import Role, User
from app.modules.auth.service import hash_password

DEFAULT_ROLES = [
    ("SUPER_ADMIN", "Full system access and configuration."),
    ("HR_ADMIN", "HR operations, employee and leave management."),
    ("PAYROLL_OFFICER", "Payroll processing and salary management."),
    ("MANAGER", "Team management and approval workflows."),
    ("RECRUITER", "Recruitment pipeline and candidate management."),
    ("EMPLOYEE", "Self-service access for employees."),
]


async def create_default_roles(db: AsyncSession) -> None:
    """Ensure the default application roles exist."""
    result = await db.execute(select(Role.name))
    existing = {row[0] for row in result.all()}

    for role_name, description in DEFAULT_ROLES:
        if role_name not in existing:
            db.add(Role(name=role_name, description=description))


async def create_default_super_admin(db: AsyncSession) -> None:
    """Create a default super admin user if requested and no users exist."""
    if not settings.CREATE_DEFAULT_SUPER_ADMIN:
        return

    result = await db.execute(select(User).limit(1))
    if result.scalar_one_or_none() is not None:
        return

    role_result = await db.execute(select(Role).where(Role.name == "SUPER_ADMIN"))
    super_role = role_result.scalar_one_or_none()
    if not super_role:
        return

    admin = User(
        email=settings.DEFAULT_SUPER_ADMIN_EMAIL,
        first_name=settings.DEFAULT_SUPER_ADMIN_FIRST_NAME,
        last_name=settings.DEFAULT_SUPER_ADMIN_LAST_NAME,
        hashed_password=hash_password(settings.DEFAULT_SUPER_ADMIN_PASSWORD),
        is_active=True,
        is_verified=True,
    )
    admin.roles.append(super_role)
    db.add(admin)
