"""
Job routes: Listing and posting jobs.

# Future Upgrade:
# - Add pagination and filtering (by location, skills, salary range)
# - Add job search with full-text search (Elasticsearch)
# - Store in database instead of in-memory
"""

from datetime import datetime
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from data.store import jobs, get_next_id, find_user_by_id
from utils.matching import calculate_match

jobs_bp = Blueprint("jobs", __name__)


@jobs_bp.route("/jobs", methods=["GET"])
@jwt_required()
def get_jobs():
    """Get all jobs. For job seekers, includes match score."""
    user_id = int(get_jwt_identity())
    user = find_user_by_id(user_id)
    claims = get_jwt()

    search = request.args.get("search", "").lower()

    result = []
    for job in jobs:
        # Simple search filter
        if search and search not in job["title"].lower() and search not in job["company"].lower():
            continue

        job_data = {
            "id": job["id"],
            "recruiter_id": job["recruiter_id"],
            "title": job["title"],
            "company": job["company"],
            "description": job["description"],
            "required_skills": job["required_skills"],
            "location": job["location"],
            "salary": job["salary"],
            "posted_at": job["posted_at"],
        }

        # Add match score for job seekers
        if claims.get("role") == "job_seeker" and user:
            match = calculate_match(user["skills"], job["required_skills"])
            job_data["matchScore"] = match["matchScore"]
            job_data["missingSkills"] = match["missingSkills"]

        # Add recruiter name
        recruiter = find_user_by_id(job["recruiter_id"])
        if recruiter:
            job_data["recruiter_name"] = recruiter["name"]

        result.append(job_data)

    # Sort by posted_at descending (newest first)
    result.sort(key=lambda x: x["posted_at"], reverse=True)

    return jsonify({"jobs": result}), 200


@jobs_bp.route("/post-job", methods=["POST"])
@jwt_required()
def post_job():
    """Post a new job (recruiter only)."""
    claims = get_jwt()
    if claims.get("role") != "recruiter":
        return jsonify({"error": "Only recruiters can post jobs"}), 403

    data = request.get_json()
    required = ["title", "company", "description", "required_skills", "location", "salary"]
    for field in required:
        if not data.get(field):
            return jsonify({"error": f"'{field}' is required"}), 400

    job = {
        "id": get_next_id("job"),
        "recruiter_id": int(get_jwt_identity()),
        "title": data["title"],
        "company": data["company"],
        "description": data["description"],
        "required_skills": data["required_skills"],
        "location": data["location"],
        "salary": data["salary"],
        "posted_at": datetime.utcnow().isoformat(),
    }
    jobs.append(job)

    return jsonify({"message": "Job posted successfully", "job": job}), 201
