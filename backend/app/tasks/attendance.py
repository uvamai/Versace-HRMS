"""Attendance-related Celery tasks."""
from app.celery_app import celery_app

@celery_app.task(name="app.tasks.attendance.process_auto_attendance")
def process_auto_attendance():
    """Process automatic attendance records."""
    # TODO: implement attendance automation
    return "auto attendance processed"
