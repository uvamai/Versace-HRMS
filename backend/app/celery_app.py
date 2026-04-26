"""
Celery application — background task queue.
"""
from celery import Celery
from app.config import settings

celery_app = Celery(
    "hrms",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=[
        "app.tasks.notifications",
        "app.tasks.leave",
        "app.tasks.attendance",
        "app.tasks.payroll",
        "app.tasks.reports",
    ],
)

celery_app.conf.update(
    task_serializer="json",
    result_serializer="json",
    accept_content=["json"],
    timezone="UTC",
    enable_utc=True,
    task_track_started=True,
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    # Beat schedule (replaces Frappe scheduler_events)
    beat_schedule={
        "process-auto-attendance-hourly": {
            "task": "app.tasks.attendance.process_auto_attendance",
            "schedule": 3600.0,
        },
        "send-birthday-reminders-daily": {
            "task": "app.tasks.notifications.send_birthday_reminders",
            "schedule": 86400.0,
        },
        "accrue-earned-leaves-daily": {
            "task": "app.tasks.leave.accrue_earned_leaves",
            "schedule": 86400.0,
        },
        "process-expired-leave-allocations-daily": {
            "task": "app.tasks.leave.process_expired_allocations",
            "schedule": 86400.0,
        },
        "close-expired-job-openings-daily": {
            "task": "app.tasks.notifications.close_expired_job_openings",
            "schedule": 86400.0,
        },
    },
)
