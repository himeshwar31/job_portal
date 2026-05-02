"""
JobConnect — Flask Backend Entry Point

A modular Flask REST API for the Job Portal application.
Uses in-memory storage for rapid development and easy database migration.

# Future Upgrade:
# - Replace in-memory storage with MongoDB (PyMongo) or MySQL (SQLAlchemy)
# - Add Socket.IO for real-time chat
# - Add rate limiting and request validation
# - Add logging and monitoring
# - Deploy with Gunicorn/uWSGI behind Nginx
"""

from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config
from data.mock_data import load_mock_data


def create_app():
    """Flask application factory."""
    app = Flask(__name__)
    app.config.from_object(Config)

    # Initialize extensions
    CORS(app)
    JWTManager(app)

    # Register blueprints
    from routes.auth import auth_bp
    from routes.profile import profile_bp
    from routes.jobs import jobs_bp
    from routes.applications import applications_bp
    from routes.chat import chat_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(profile_bp)
    app.register_blueprint(jobs_bp)
    app.register_blueprint(applications_bp)
    app.register_blueprint(chat_bp)

    # Health check endpoint
    @app.route("/", methods=["GET"])
    def health():
        return jsonify({
            "status": "running",
            "app": "JobConnect API",
            "version": "1.0.0",
        }), 200

    # Load mock data
    with app.app_context():
        load_mock_data()

    return app


if __name__ == "__main__":
    app = create_app()
    print("\n🚀 JobConnect API running at http://localhost:5000\n")
    app.run(host="0.0.0.0", port=5000, debug=True)
