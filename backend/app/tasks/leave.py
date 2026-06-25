"""Leave-related Celery tasks."""
from app.celery_app import celery_app

@celery_app.task(name="app.tasks.leave.accrue_earned_leaves")
def accrue_earned_leaves():
    """Accrue earned leaves for users."""
    # TODO: implement leave accrual
    return "earned leaves accrued"

@celery_app.task(name="app.tasks.leave.process_expired_allocations")
def process_expired_allocations():
    """Process expired leave allocations."""
    # TODO: implement expired allocation processing
    return "expired allocations processed"
