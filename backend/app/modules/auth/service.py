"""
Auth service — JWT creation, password hashing, token management.
"""
import hashlib
import uuid
from datetime import datetime, timedelta, timezone

from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.modules.auth.models import RefreshToken, Role, User
from app.modules.auth.schemas import RegisterRequest, TokenResponse, UserResponse

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# ── Password Utilities ────────────────────────────────────────

def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


# ── JWT Utilities ─────────────────────────────────────────────

def create_access_token(user_id: str, roles: list[str]) -> str:
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES
    )
    payload = {
        "sub": user_id,
        "roles": roles,
        "type": "access",
        "exp": expire,
        "iat": datetime.now(timezone.utc),
        "jti": str(uuid.uuid4()),
    }
    return jwt.encode(payload, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)


def create_refresh_token_str() -> str:
    return str(uuid.uuid4()) + "-" + str(uuid.uuid4())


def hash_token(token: str) -> str:
    return hashlib.sha256(token.encode()).hexdigest()


def decode_access_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
        if payload.get("type") != "access":
            raise ValueError("Invalid token type")
        return payload
    except JWTError as e:
        raise ValueError(f"Invalid token: {e}") from e


def build_token_response(access_token: str, refresh_token_str: str) -> TokenResponse:
    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token_str,
        expires_in=settings.JWT_ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


# ── Auth Service ──────────────────────────────────────────────

class AuthService:

    def __init__(self, db: AsyncSession):
        self.db = db

    async def register(self, data: RegisterRequest) -> User:
        """Create a new user with default EMPLOYEE role."""
        # Check email uniqueness
        existing = await self.db.execute(select(User).where(User.email == data.email))
        if existing.scalar_one_or_none():
            raise ValueError("Email already registered")

        # Fetch default role
        role_result = await self.db.execute(select(Role).where(Role.name == "EMPLOYEE"))
        employee_role = role_result.scalar_one_or_none()

        user = User(
            email=data.email,
            first_name=data.first_name,
            last_name=data.last_name,
            hashed_password=hash_password(data.password),
            is_active=True,
        )
        if employee_role:
            user.roles.append(employee_role)

        self.db.add(user)
        await self.db.flush()
        return user

    async def login(self, email: str, password: str) -> tuple[User, str, str]:
        """Authenticate and return (user, access_token, refresh_token)."""
        result = await self.db.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()

        if not user or not verify_password(password, user.hashed_password):
            raise ValueError("Invalid email or password")
        if not user.is_active:
            raise ValueError("Account is disabled")

        # Create tokens
        access_token = create_access_token(str(user.id), user.role_names)
        refresh_token_str = create_refresh_token_str()

        # Store hashed refresh token
        refresh_token = RefreshToken(
            user_id=user.id,
            token_hash=hash_token(refresh_token_str),
            expires_at=datetime.now(timezone.utc) + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS),
        )
        self.db.add(refresh_token)

        # Update last login
        user.last_login = datetime.now(timezone.utc)

        await self.db.flush()
        return user, access_token, refresh_token_str

    async def refresh(self, refresh_token_str: str) -> tuple[str, str]:
        """Rotate refresh token and return new (access_token, refresh_token)."""
        token_hash = hash_token(refresh_token_str)
        result = await self.db.execute(
            select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        )
        stored_token = result.scalar_one_or_none()

        if not stored_token or not stored_token.is_valid:
            raise ValueError("Invalid or expired refresh token")

        # Revoke old token (rotation)
        stored_token.revoked_at = datetime.now(timezone.utc)

        # Issue new tokens
        user = stored_token.user
        new_access = create_access_token(str(user.id), user.role_names)
        new_refresh_str = create_refresh_token_str()

        new_refresh = RefreshToken(
            user_id=user.id,
            token_hash=hash_token(new_refresh_str),
            expires_at=datetime.now(timezone.utc) + timedelta(days=settings.JWT_REFRESH_TOKEN_EXPIRE_DAYS),
        )
        self.db.add(new_refresh)
        await self.db.flush()

        return new_access, new_refresh_str

    async def logout(self, refresh_token_str: str) -> None:
        """Revoke the refresh token."""
        token_hash = hash_token(refresh_token_str)
        result = await self.db.execute(
            select(RefreshToken).where(RefreshToken.token_hash == token_hash)
        )
        stored_token = result.scalar_one_or_none()
        if stored_token:
            stored_token.revoked_at = datetime.now(timezone.utc)
            await self.db.flush()

    @staticmethod
    def to_user_response(user: User) -> UserResponse:
        return UserResponse(
            id=user.id,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
            roles=user.role_names,
            last_login=user.last_login,
            created_at=user.created_at,
        )
