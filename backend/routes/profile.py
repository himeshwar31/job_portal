"""
User profile routes.

# Future Upgrade:
# - Add profile picture upload
# - Add resume/CV upload
# - Store in database instead of in-memory
"""

from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from data.store import find_user_by_id

profile_bp = Blueprint("profile", __name__)


@profile_bp.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    """Get current user's profile."""
    user_id = int(get_jwt_identity())
    user = find_user_by_id(user_id)

    if not user:
        return jsonify({"error": "User not found"}), 404

    return jsonify({
        "id": user["id"],
        "name": user["name"],
        "email": user["email"],
        "role": user["role"],
        "skills": user["skills"],
        "education": user["education"],
        "experience": user["experience"],
        "created_at": user["created_at"],
    }), 200


@profile_bp.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    """Update current user's profile (skills, education, experience)."""
    user_id = int(get_jwt_identity())
    user = find_user_by_id(user_id)

    if not user:
        return jsonify({"error": "User not found"}), 404

    data = request.get_json()

    # Update allowed fields
    if "name" in data:
        user["name"] = data["name"]
    if "skills" in data:
        user["skills"] = data["skills"]
    if "education" in data:
        user["education"] = data["education"]
    if "experience" in data:
        user["experience"] = data["experience"]

    return jsonify({
        "message": "Profile updated successfully",
        "user": {
            "id": user["id"],
            "name": user["name"],
            "email": user["email"],
            "role": user["role"],
            "skills": user["skills"],
            "education": user["education"],
            "experience": user["experience"],
        },
    }), 200
