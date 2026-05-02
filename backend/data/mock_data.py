"""
Mock data to pre-populate the in-memory store on startup.

# Future Upgrade:
# - Replace with database seed scripts
# - Use migration tools (Alembic for SQL, mongoimport for MongoDB)
"""

from datetime import datetime, timedelta
from werkzeug.security import generate_password_hash
from data.store import users, jobs, applications, messages, counters


def load_mock_data():
    """Load sample data into the in-memory store."""

    # ─── Users ───────────────────────────────────────────
    mock_users = [
        {
            "id": 1,
            "name": "Alice Johnson",
            "email": "alice@example.com",
            "password_hash": generate_password_hash("password123"),
            "role": "job_seeker",
            "skills": ["Python", "Flask", "React", "SQL", "Docker"],
            "education": "B.Tech in Computer Science, IIT Delhi (2020)",
            "experience": "3 years as Full Stack Developer at TechCorp",
            "created_at": (datetime.utcnow() - timedelta(days=30)).isoformat(),
        },
        {
            "id": 2,
            "name": "Bob Smith",
            "email": "bob@example.com",
            "password_hash": generate_password_hash("password123"),
            "role": "job_seeker",
            "skills": ["Java", "Spring Boot", "AWS", "Kubernetes", "MySQL"],
            "education": "M.Tech in Software Engineering, NIT Trichy (2019)",
            "experience": "5 years as Backend Engineer at CloudSoft",
            "created_at": (datetime.utcnow() - timedelta(days=25)).isoformat(),
        },
        {
            "id": 3,
            "name": "Carol Williams",
            "email": "carol@example.com",
            "password_hash": generate_password_hash("password123"),
            "role": "job_seeker",
            "skills": ["Flutter", "Dart", "Firebase", "UI/UX", "Figma"],
            "education": "B.Des in Interaction Design, NID (2021)",
            "experience": "2 years as Mobile Developer at AppWorks",
            "created_at": (datetime.utcnow() - timedelta(days=20)).isoformat(),
        },
        {
            "id": 4,
            "name": "David Chen",
            "email": "david@example.com",
            "password_hash": generate_password_hash("password123"),
            "role": "recruiter",
            "skills": [],
            "education": "",
            "experience": "HR Manager at InnoTech Solutions",
            "created_at": (datetime.utcnow() - timedelta(days=40)).isoformat(),
        },
        {
            "id": 5,
            "name": "Emma Wilson",
            "email": "emma@example.com",
            "password_hash": generate_password_hash("password123"),
            "role": "recruiter",
            "skills": [],
            "education": "",
            "experience": "Talent Acquisition Lead at FutureCorp",
            "created_at": (datetime.utcnow() - timedelta(days=35)).isoformat(),
        },
    ]

    # ─── Jobs ────────────────────────────────────────────
    mock_jobs = [
        {
            "id": 1,
            "recruiter_id": 4,
            "title": "Senior Python Developer",
            "company": "InnoTech Solutions",
            "description": "We are looking for an experienced Python developer to build scalable backend services. You will work with microservices architecture, REST APIs, and cloud deployment.",
            "required_skills": ["Python", "Flask", "Docker", "SQL", "REST API"],
            "location": "Bangalore, India",
            "salary": "₹18,00,000 - ₹25,00,000",
            "posted_at": (datetime.utcnow() - timedelta(days=5)).isoformat(),
        },
        {
            "id": 2,
            "recruiter_id": 4,
            "title": "Full Stack Engineer",
            "company": "InnoTech Solutions",
            "description": "Join our team to build end-to-end web applications. You will be responsible for both frontend (React) and backend (Python/Node.js) development.",
            "required_skills": ["Python", "React", "JavaScript", "SQL", "Git"],
            "location": "Hyderabad, India",
            "salary": "₹15,00,000 - ₹22,00,000",
            "posted_at": (datetime.utcnow() - timedelta(days=3)).isoformat(),
        },
        {
            "id": 3,
            "recruiter_id": 5,
            "title": "Flutter Mobile Developer",
            "company": "FutureCorp",
            "description": "Develop cross-platform mobile applications using Flutter. You will create beautiful, responsive UIs and integrate with backend APIs.",
            "required_skills": ["Flutter", "Dart", "Firebase", "REST API", "Git"],
            "location": "Mumbai, India",
            "salary": "₹12,00,000 - ₹18,00,000",
            "posted_at": (datetime.utcnow() - timedelta(days=7)).isoformat(),
        },
        {
            "id": 4,
            "recruiter_id": 5,
            "title": "Cloud DevOps Engineer",
            "company": "FutureCorp",
            "description": "Manage cloud infrastructure and CI/CD pipelines. Experience with AWS or Azure, containerization, and monitoring tools is required.",
            "required_skills": ["AWS", "Kubernetes", "Docker", "Terraform", "Jenkins"],
            "location": "Remote",
            "salary": "₹20,00,000 - ₹30,00,000",
            "posted_at": (datetime.utcnow() - timedelta(days=2)).isoformat(),
        },
        {
            "id": 5,
            "recruiter_id": 4,
            "title": "UI/UX Designer & Developer",
            "company": "InnoTech Solutions",
            "description": "Design and implement stunning user interfaces. Must be proficient in both design tools and frontend frameworks.",
            "required_skills": ["Figma", "UI/UX", "React", "CSS", "JavaScript"],
            "location": "Pune, India",
            "salary": "₹10,00,000 - ₹16,00,000",
            "posted_at": (datetime.utcnow() - timedelta(days=1)).isoformat(),
        },
    ]

    # ─── Applications ────────────────────────────────────
    mock_applications = [
        {
            "id": 1,
            "job_id": 1,
            "user_id": 1,
            "status": "pending",
            "match_score": 60.0,
            "missing_skills": ["REST API"],
            "applied_at": (datetime.utcnow() - timedelta(days=4)).isoformat(),
            "interview_date": None,
        },
        {
            "id": 2,
            "job_id": 3,
            "user_id": 3,
            "status": "accepted",
            "match_score": 60.0,
            "missing_skills": ["REST API", "Git"],
            "applied_at": (datetime.utcnow() - timedelta(days=6)).isoformat(),
            "interview_date": (datetime.utcnow() + timedelta(days=3)).isoformat(),
        },
        {
            "id": 3,
            "job_id": 4,
            "user_id": 2,
            "status": "pending",
            "match_score": 40.0,
            "missing_skills": ["Docker", "Terraform", "Jenkins"],
            "applied_at": (datetime.utcnow() - timedelta(days=1)).isoformat(),
            "interview_date": None,
        },
    ]

    # ─── Messages ────────────────────────────────────────
    mock_messages = [
        {
            "id": 1,
            "sender_id": 4,
            "receiver_id": 1,
            "content": "Hi Alice! We reviewed your application for the Senior Python Developer role. Impressive skills!",
            "timestamp": (datetime.utcnow() - timedelta(hours=5)).isoformat(),
        },
        {
            "id": 2,
            "sender_id": 1,
            "receiver_id": 4,
            "content": "Thank you, David! I'm very excited about this opportunity. When can we discuss the next steps?",
            "timestamp": (datetime.utcnow() - timedelta(hours=4)).isoformat(),
        },
        {
            "id": 3,
            "sender_id": 4,
            "receiver_id": 1,
            "content": "Let's schedule a technical interview for next week. Does Tuesday work for you?",
            "timestamp": (datetime.utcnow() - timedelta(hours=3)).isoformat(),
        },
        {
            "id": 4,
            "sender_id": 5,
            "receiver_id": 3,
            "content": "Hi Carol! Your Flutter portfolio is outstanding. We'd love to chat about the Mobile Developer position.",
            "timestamp": (datetime.utcnow() - timedelta(hours=2)).isoformat(),
        },
        {
            "id": 5,
            "sender_id": 3,
            "receiver_id": 5,
            "content": "Hi Emma! That sounds wonderful. I'm very interested in the role at FutureCorp!",
            "timestamp": (datetime.utcnow() - timedelta(hours=1)).isoformat(),
        },
    ]

    # Load into store
    users.clear()
    users.extend(mock_users)

    jobs.clear()
    jobs.extend(mock_jobs)

    applications.clear()
    applications.extend(mock_applications)

    messages.clear()
    messages.extend(mock_messages)

    # Set counters to max IDs
    counters["user_id"] = max(u["id"] for u in users)
    counters["job_id"] = max(j["id"] for j in jobs)
    counters["application_id"] = max(a["id"] for a in applications)
    counters["message_id"] = max(m["id"] for m in messages)

    print(f"✅ Mock data loaded: {len(users)} users, {len(jobs)} jobs, "
          f"{len(applications)} applications, {len(messages)} messages")
