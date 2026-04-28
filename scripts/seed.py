import asyncio

from backend.app.database import engine, AsyncSessionLocal, Base
from backend.app.modules.auth.seed import create_default_roles, create_default_super_admin


async def main() -> None:
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as session:
        await create_default_roles(session)
        await create_default_super_admin(session)
        await session.commit()


if __name__ == "__main__":
    asyncio.run(main())
