"""
Skill matching algorithm for the Job Portal.

Calculates how well a candidate's skills match a job's required skills.

Match Score = (Matching Skills / Required Skills) * 100

# Future Upgrade:
# - Use NLP for semantic skill matching (e.g., "JS" == "JavaScript")
# - Implement ML-based matching using embeddings
# - Factor in experience level and education relevance
"""


def calculate_match(user_skills: list, required_skills: list) -> dict:
    """
    Calculate match score between user skills and job required skills.

    Args:
        user_skills: List of skills the user has
        required_skills: List of skills required for the job

    Returns:
        dict with matchScore (float) and missingSkills (list)
    """
    if not required_skills:
        return {"matchScore": 100.0, "missingSkills": []}

    # Normalize skills to lowercase for comparison
    user_skills_lower = {s.lower().strip() for s in user_skills}
    required_skills_lower = {s.lower().strip() for s in required_skills}

    # Find matching skills
    matching = user_skills_lower & required_skills_lower
    score = (len(matching) / len(required_skills_lower)) * 100

    # Find missing skills (preserve original casing from required_skills)
    missing = [
        skill for skill in required_skills
        if skill.lower().strip() not in user_skills_lower
    ]

    return {
        "matchScore": round(score, 1),
        "missingSkills": missing,
    }
