"""
Application configuration using Pydantic Settings.
Reads from environment variables / .env file.
"""
from functools import lru_cache
from pathlib import Path
from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict


ROOT_DIR = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(ROOT_DIR / ".env"),
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ── App ──────────────────────────────────────────────────
    APP_NAME: str = "Versace HRMS"
    APP_ENV: str = "development"
    DEBUG: bool = True
    SECRET_KEY: str = "CHANGE_ME_IN_PRODUCTION"
    ALLOWED_HOSTS: str = "localhost,127.0.0.1"

    @property
    def CORS_ORIGINS(self) -> List[str]:
        base = [
            "http://localhost:3000",   # Vue dev server
            "http://127.0.0.1:3000",
            "http://localhost:3000",   # alt
            "http://localhost:80",
        ]
        if self.APP_ENV == "production":
            base = []  # set explicitly in prod
        return base

    # ── Database ─────────────────────────────────────────────
    DATABASE_URL: str = "postgresql+asyncpg://hrms:hrms_password@localhost:5434/hrms_db"
    DATABASE_POOL_SIZE: int = 10
    DATABASE_MAX_OVERFLOW: int = 20

    # ── Redis ────────────────────────────────────────────────
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_CACHE_URL: str = "redis://localhost:6379/1"
    CELERY_BROKER_URL: str = "redis://localhost:6379/2"
    CELERY_RESULT_BACKEND: str = "redis://localhost:6379/3"

    # ── JWT ──────────────────────────────────────────────────
    JWT_SECRET_KEY: str = "CHANGE_ME_IN_PRODUCTION"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # ── Email ────────────────────────────────────────────────
    SENDGRID_API_KEY: str = ""
    EMAIL_FROM: str = "noreply@versace-hrms.com"
    EMAIL_FROM_NAME: str = "Versace HRMS"

    # ── Storage ──────────────────────────────────────────────
    STORAGE_BACKEND: str = "LOCAL"      # LOCAL | S3
    LOCAL_STORAGE_PATH: str = "/app/uploads"
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_S3_BUCKET: str = ""
    AWS_S3_REGION: str = "us-east-1"

    # ── Default admin bootstrap (development only) ─────────────
    CREATE_DEFAULT_SUPER_ADMIN: bool = False
    DEFAULT_SUPER_ADMIN_EMAIL: str = "admin@versace-hrms.local"
    DEFAULT_SUPER_ADMIN_PASSWORD: str = "Admin1234!"
    DEFAULT_SUPER_ADMIN_FIRST_NAME: str = "Super"
    DEFAULT_SUPER_ADMIN_LAST_NAME: str = "Admin"

    # ── Pagination defaults ───────────────────────────────────
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
