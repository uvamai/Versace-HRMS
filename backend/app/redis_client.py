"""
Redis client — shared across the app.
"""
from redis.asyncio import Redis, from_url

from app.config import settings

# Main Redis connection (sessions, misc)
redis_client: Redis = from_url(
    settings.REDIS_URL,
    encoding="utf-8",
    decode_responses=True,
)

# Cache-specific connection
cache_client: Redis = from_url(
    settings.REDIS_CACHE_URL,
    encoding="utf-8",
    decode_responses=True,
)


async def get_redis() -> Redis:
    """FastAPI dependency."""
    return redis_client


class CacheKeys:
    """Centralised cache key definitions."""
    EMPLOYEE = "employee:{id}"
    EMPLOYEE_LIST = "employees:list:{page}:{size}"
    LEAVE_BALANCE = "leave_balance:{employee_id}:{leave_type_id}"
    USER_PERMISSIONS = "user_permissions:{user_id}"

    @staticmethod
    def employee(employee_id: str) -> str:
        return f"employee:{employee_id}"

    @staticmethod
    def leave_balance(employee_id: str, leave_type_id: str) -> str:
        return f"leave_balance:{employee_id}:{leave_type_id}"

    @staticmethod
    def user_permissions(user_id: str) -> str:
        return f"user_permissions:{user_id}"
