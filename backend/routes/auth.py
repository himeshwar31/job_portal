"""
Authentication routes: Register and Login.

# Future Upgrade:
# - Store users in MongoDB/MySQL instead of in-memory list
# - Add email verification
# - Add OAuth (Google, GitHub) login
# - Add refresh tokens
"""

from datetime import datetime
from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash
from data.store import users, get_next_id, find_user_by_email

auth_bp = Blueprint("auth", __name__)


@auth_bp.route("/register", methods=["POST"])
def register():
    """Register a new user (job_seeker or recruiter)."""
    data = request.get_json()

    # Validate required fields
    required = ["name", "email", "password", "role"]
    for field in required:
        if not data.get(field):
            return jsonify({"error": f"'{field}' is required"}), 400

    # Validate role
    if data["role"] not in ("job_seeker", "recruiter"):
        return jsonify({"error": "Role must be 'job_seeker' or 'recruiter'"}), 400

    # Check if email already exists
    if find_user_by_email(data["email"]):
        return jsonify({"error": "Email already registered"}), 409

    # Create user
    user = {
        "id": get_next_id("user"),
        "name": data["name"],
        "email": data["email"].lower().strip(),
        "password_hash": generate_password_hash(data["password"]),
        "role": data["role"],
        "skills": data.get("skills", []),
        "education": data.get("education", ""),
        "experience": data.get("experience", ""),
        "created_at": datetime.utcnow().isoformat(),
    }
    users.append(user)

    # Create JWT token
    access_token = create_access_token(
        identity=str(user["id"]),
        additional_claims={"role": user["role"], "name": user["name"]},
    )

    return jsonify({
        "message": "Registration successful",
        "token": access_token,
        "user": {
            "id": user["id"],
            "name": user["name"],
            "email": user["email"],
            "role": user["role"],
        },
    }), 201


@auth_bp.route("/login", methods=["POST"])
def login():
    """Login and return JWT token."""
    data = request.get_json()

    if not data.get("email") or not data.get("password"):
        return jsonify({"error": "Email and password are required"}), 400

    user = find_user_by_email(data["email"])
    if not user or not check_password_hash(user["password_hash"], data["password"]):
        return jsonify({"error": "Invalid email or password"}), 401

    access_token = create_access_token(
        identity=str(user["id"]),
        additional_claims={"role": user["role"], "name": user["name"]},
    )

    return jsonify({
        "message": "Login successful",
        "token": access_token,
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
