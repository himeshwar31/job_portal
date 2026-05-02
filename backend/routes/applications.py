"""
Application routes: Apply, view applications, manage applicants.

# Future Upgrade:
# - Add application status history/audit trail
# - Send email notifications on status change
# - Store in database instead of in-memory
"""

from datetime import datetime
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from data.store import (
    applications, jobs, get_next_id,
    find_user_by_id, find_job_by_id, find_application,
)
from utils.matching import calculate_match

applications_bp = Blueprint("applications", __name__)


@applications_bp.route("/apply", methods=["POST"])
@jwt_required()
def apply_for_job():
    """Job seeker applies for a job. Computes match score automatically."""
    claims = get_jwt()
    if claims.get("role") != "job_seeker":
        return jsonify({"error": "Only job seekers can apply for jobs"}), 403

    user_id = int(get_jwt_identity())
    data = request.get_json()

    job_id = data.get("job_id")
    if not job_id:
        return jsonify({"error": "'job_id' is required"}), 400

    job = find_job_by_id(job_id)
    if not job:
        return jsonify({"error": "Job not found"}), 404

    # Check if already applied
    if find_application(job_id, user_id):
        return jsonify({"error": "You have already applied for this job"}), 409

    # Calculate match score
    user = find_user_by_id(user_id)
    match = calculate_match(user["skills"], job["required_skills"])

    application = {
        "id": get_next_id("application"),
        "job_id": job_id,
        "user_id": user_id,
        "status": "pending",
        "match_score": match["matchScore"],
        "missing_skills": match["missingSkills"],
        "applied_at": datetime.utcnow().isoformat(),
        "interview_date": None,
    }
    applications.append(application)

    return jsonify({
        "message": "Application submitted successfully",
        "application": application,
    }), 201


@applications_bp.route("/applications", methods=["GET"])
@jwt_required()
def get_applications():
    """Job seeker views their applications."""
    user_id = int(get_jwt_identity())

    user_apps = []
    for app in applications:
        if app["user_id"] == user_id:
            job = find_job_by_id(app["job_id"])
            app_data = {
                **app,
                "job_title": job["title"] if job else "Unknown",
                "company": job["company"] if job else "Unknown",
                "location": job["location"] if job else "Unknown",
            }
            user_apps.append(app_data)

    # Sort by applied_at descending
    user_apps.sort(key=lambda x: x["applied_at"], reverse=True)

    return jsonify({"applications": user_apps}), 200


@applications_bp.route("/applicants", methods=["GET"])
@jwt_required()
def get_applicants():
    """Recruiter views applicants for their posted jobs."""
    claims = get_jwt()
    if claims.get("role") != "recruiter":
        return jsonify({"error": "Only recruiters can view applicants"}), 403

    recruiter_id = int(get_jwt_identity())

    # Get all jobs posted by this recruiter
    recruiter_job_ids = [j["id"] for j in jobs if j["recruiter_id"] == recruiter_id]

    # Optional filter by job_id
    filter_job_id = request.args.get("job_id", type=int)

    result = []
    for app in applications:
        if app["job_id"] in recruiter_job_ids:
            if filter_job_id and app["job_id"] != filter_job_id:
                continue

            user = find_user_by_id(app["user_id"])
            job = find_job_by_id(app["job_id"])

            app_data = {
                **app,
                "applicant_name": user["name"] if user else "Unknown",
                "applicant_email": user["email"] if user else "Unknown",
                "applicant_skills": user["skills"] if user else [],
                "applicant_education": user["education"] if user else "",
                "applicant_experience": user["experience"] if user else "",
                "job_title": job["title"] if job else "Unknown",
                "company": job["company"] if job else "Unknown",
            }
            result.append(app_data)

    # Sort by applied_at descending
    result.sort(key=lambda x: x["applied_at"], reverse=True)

    return jsonify({"applicants": result}), 200


@applications_bp.route("/update-status", methods=["POST"])
@jwt_required()
def update_status():
    """Recruiter accepts or rejects an application."""
    claims = get_jwt()
    if claims.get("role") != "recruiter":
        return jsonify({"error": "Only recruiters can update application status"}), 403

    data = request.get_json()
    application_id = data.get("application_id")
    new_status = data.get("status")

    if not application_id or not new_status:
        return jsonify({"error": "'application_id' and 'status' are required"}), 400

    if new_status not in ("accepted", "rejected"):
        return jsonify({"error": "Status must be 'accepted' or 'rejected'"}), 400

    recruiter_id = int(get_jwt_identity())
    recruiter_job_ids = [j["id"] for j in jobs if j["recruiter_id"] == recruiter_id]

    for app in applications:
        if app["id"] == application_id and app["job_id"] in recruiter_job_ids:
            app["status"] = new_status
            return jsonify({
                "message": f"Application {new_status}",
                "application": app,
            }), 200

    return jsonify({"error": "Application not found or not authorized"}), 404


@applications_bp.route("/schedule-interview", methods=["POST"])
@jwt_required()
def schedule_interview():
    """Recruiter schedules an interview for an application."""
    claims = get_jwt()
    if claims.get("role") != "recruiter":
        return jsonify({"error": "Only recruiters can schedule interviews"}), 403

    data = request.get_json()
    application_id = data.get("application_id")
    interview_date = data.get("interview_date")

    if not application_id or not interview_date:
        return jsonify({"error": "'application_id' and 'interview_date' are required"}), 400

    recruiter_id = int(get_jwt_identity())
    recruiter_job_ids = [j["id"] for j in jobs if j["recruiter_id"] == recruiter_id]

    for app in applications:
        if app["id"] == application_id and app["job_id"] in recruiter_job_ids:
            app["interview_date"] = interview_date
            app["status"] = "accepted"
            return jsonify({
                "message": "Interview scheduled successfully",
                "application": app,
            }), 200

    return jsonify({"error": "Application not found or not authorized"}), 404
