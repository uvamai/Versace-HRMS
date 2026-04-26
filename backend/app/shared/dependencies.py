"""
Shared FastAPI dependencies — authentication, authorization, pagination.
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.modules.auth.models import User
from app.modules.auth.service import decode_access_token

security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db),
) -> User:
    """Decode JWT and return the authenticated user."""
    token = credentials.credentials
    try:
        payload = decode_access_token(token)
        user_id = payload.get("sub")
        if not user_id:
            raise ValueError("Missing user ID in token")
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"},
        )

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )
    return user


def require_roles(*role_names: str):
    """FastAPI dependency factory — require one of the given roles."""
    async def _check(current_user: User = Depends(get_current_user)) -> User:
        if not current_user.has_any_role(*role_names):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Requires one of roles: {', '.join(role_names)}",
            )
        return current_user
    return _check


# ── Pre-built role dependencies ───────────────────────────────
require_hr_admin = require_roles("HR_ADMIN", "SUPER_ADMIN")
require_manager = require_roles("MANAGER", "HR_ADMIN", "SUPER_ADMIN")
require_payroll = require_roles("PAYROLL_OFFICER", "HR_ADMIN", "SUPER_ADMIN")
require_recruiter = require_roles("RECRUITER", "HR_ADMIN", "SUPER_ADMIN")


# ── Pagination ────────────────────────────────────────────────
class PaginationParams:
    def __init__(self, page: int = 1, size: int = 20):
        self.page = max(1, page)
        self.size = min(size, 100)

    @property
    def offset(self) -> int:
        return (self.page - 1) * self.size
