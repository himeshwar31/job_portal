"""
In-memory data store for the Job Portal.

# Future Upgrade:
# - Replace these lists/dicts with database models (SQLAlchemy / PyMongo)
# - Each list becomes a database collection/table
# - IDs become auto-generated database IDs
"""

# Auto-increment counters
counters = {
    "user_id": 0,
    "job_id": 0,
    "application_id": 0,
    "message_id": 0,
}

# In-memory storage
users = []
# Schema: {
#   "id": int,
#   "name": str,
#   "email": str,
#   "password_hash": str,
#   "role": "job_seeker" | "recruiter",
#   "skills": [str],
#   "education": str,
#   "experience": str,
#   "created_at": str (ISO format)
# }

jobs = []
# Schema: {
#   "id": int,
#   "recruiter_id": int,
#   "title": str,
#   "company": str,
#   "description": str,
#   "required_skills": [str],
#   "location": str,
#   "salary": str,
#   "posted_at": str (ISO format)
# }

applications = []
# Schema: {
#   "id": int,
#   "job_id": int,
#   "user_id": int,
#   "status": "pending" | "accepted" | "rejected",
#   "match_score": float,
#   "missing_skills": [str],
#   "applied_at": str (ISO format),
#   "interview_date": str | None
# }

messages = []
# Schema: {
#   "id": int,
#   "sender_id": int,
#   "receiver_id": int,
#   "content": str,
#   "timestamp": str (ISO format)
# }


def get_next_id(entity: str) -> int:
    """Get next auto-increment ID for an entity."""
    counters[f"{entity}_id"] += 1
    return counters[f"{entity}_id"]


def find_user_by_email(email: str):
    """Find a user by email address."""
    for user in users:
        if user["email"].lower() == email.lower():
            return user
    return None


def find_user_by_id(user_id: int):
    """Find a user by ID."""
    for user in users:
        if user["id"] == user_id:
            return user
    return None


def find_job_by_id(job_id: int):
    """Find a job by ID."""
    for job in jobs:
        if job["id"] == job_id:
            return job
    return None


def find_application(job_id: int, user_id: int):
    """Find an application by job_id and user_id."""
    for app in applications:
        if app["job_id"] == job_id and app["user_id"] == user_id:
            return app
    return None
