"""Attendance management router — placeholder for Phase 2."""
from fastapi import APIRouter, Depends
from app.shared.dependencies import get_current_user
from app.modules.auth.models import User

router = APIRouter()


@router.get("")
async def attendance_status(_: User = Depends(get_current_user)):
    return {"message": "Attendance management — Phase 2", "status": "coming_soon"}
