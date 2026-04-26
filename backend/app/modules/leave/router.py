"""Leave management router — placeholder for Phase 2."""
from fastapi import APIRouter, Depends
from app.shared.dependencies import get_current_user
from app.modules.auth.models import User

router = APIRouter()


@router.get("")
async def list_leave_types(_: User = Depends(get_current_user)):
    return {"message": "Leave management — Phase 2", "status": "coming_soon"}
