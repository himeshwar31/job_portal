"""
Flask application configuration.

# Future Upgrade:
# - Move secrets to environment variables or a .env file
# - Add database URI configuration (MongoDB/MySQL)
"""

from datetime import timedelta


class Config:
    # JWT Configuration
    JWT_SECRET_KEY = "job-portal-super-secret-key-change-in-production"
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)

    # CORS
    CORS_ORIGINS = ["*"]  # Restrict in production
