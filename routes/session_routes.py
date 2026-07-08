from fastapi import APIRouter, Depends, HTTPException
from models import WorkoutSession, Exercise, User
from sqlalchemy.orm import Session
from sqlalchemy import func
from database import get_db
from schemas import StartSessionRequest, EndSessionRequest
from datetime import datetime
from ai.pose_analyzer import rep_state

router = APIRouter(prefix="/sessions", tags=["sessions"])

@router.post("/start", status_code=201)
def start_session(req: StartSessionRequest, db: Session = Depends(get_db)):
    session = WorkoutSession(user_id=req.user_id, exercise_id=req.exercise_id)
    db.add(session)
    db.commit()
    db.refresh(session)
    return {"session_id": session.id, "start_time": session.start_time.isoformat()}

@router.post("/end")
def end_session(req: EndSessionRequest, db: Session = Depends(get_db)):
    session = db.query(WorkoutSession).filter(WorkoutSession.id == req.session_id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    state = rep_state.get(req.session_id, {"count": 0, "correct": 0})
    total_reps = state.get("count", 0)
    correct_reps = state.get("correct", 0)
    session.end_time = datetime.utcnow()
    session.total_reps = total_reps
    session.correct_reps = correct_reps
    session.accuracy_percent = round(
        (correct_reps / total_reps * 100) if total_reps > 0 else 0.0, 1
    )
    session.duration_seconds = int((session.end_time - session.start_time).total_seconds())
    db.commit()
    if req.session_id in rep_state:
        del rep_state[req.session_id]
    return {
        "total_reps": session.total_reps,
        "correct_reps": session.correct_reps,
        "accuracy_percent": session.accuracy_percent,
        "duration_seconds": session.duration_seconds
    }

@router.get("/history/{user_id}")
def get_history(user_id: int, db: Session = Depends(get_db)):
    sessions = db.query(WorkoutSession).filter(
        WorkoutSession.user_id == user_id,
        WorkoutSession.end_time != None
    ).order_by(WorkoutSession.start_time.desc()).all()
    return [
        {
            "session_id": s.id,
            "exercise_name": s.exercise.name if s.exercise else "",
            "total_reps": s.total_reps,
            "accuracy_percent": s.accuracy_percent,
            "duration_seconds": s.duration_seconds,
            "start_time": s.start_time.isoformat() if s.start_time else ""
        }
        for s in sessions
    ]

@router.get("/summary/{user_id}")
def get_summary(user_id: int, db: Session = Depends(get_db)):
    sessions = db.query(WorkoutSession).filter(
        WorkoutSession.user_id == user_id,
        WorkoutSession.end_time != None
    ).all()

    total_workouts = len(sessions)
    avg_accuracy = round(
        sum(s.accuracy_percent or 0 for s in sessions) / total_workouts, 1
    ) if total_workouts > 0 else 0.0

    reps_by_exercise = {}
    for s in sessions:
        name = s.exercise.name if s.exercise else "Unknown"
        reps_by_exercise[name] = reps_by_exercise.get(name, 0) + (s.total_reps or 0)

    count_by_exercise = {}
    for s in sessions:
        name = s.exercise.name if s.exercise else "Unknown"
        count_by_exercise[name] = count_by_exercise.get(name, 0) + 1

    return {
        "total_workouts": total_workouts,
        "average_accuracy": avg_accuracy,
        "reps_by_exercise": reps_by_exercise,
        "sessions_by_exercise": count_by_exercise
    }
@router.get("/admin-summary")
def get_admin_summary(db: Session = Depends(get_db)):

        sessions = db.query(WorkoutSession).filter(
            WorkoutSession.end_time != None
        ).all()

        weekly_sessions = {
            "Mon": 0,
            "Tue": 0,
            "Wed": 0,
            "Thu": 0,
            "Fri": 0,
            "Sat": 0,
            "Sun": 0,
        }

        days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        for session in sessions:
            day = days[session.start_time.weekday()]
            weekly_sessions[day] += 1

        total_users = db.query(User).count()
        total_sessions = len(sessions)

        avg_accuracy = round(
            sum(s.accuracy_percent or 0 for s in sessions) / total_sessions, 1
        ) if total_sessions > 0 else 0.0

        active_exercises = db.query(Exercise).filter(
            Exercise.is_active == True
        ).count()

        reps_by_exercise = {}
        sessions_by_exercise = {}

        for session in sessions:
            name = session.exercise.name if session.exercise else "Unknown"

            reps_by_exercise[name] = (
                reps_by_exercise.get(name, 0) +
                (session.total_reps or 0)
            )

            sessions_by_exercise[name] = (
                sessions_by_exercise.get(name, 0) + 1
            )

        return {
            "total_users": total_users,
            "total_sessions": total_sessions,
            "average_accuracy": avg_accuracy,
            "active_exercises": active_exercises,
            "reps_by_exercise": reps_by_exercise,
            "sessions_by_exercise": sessions_by_exercise,
            "weekly_sessions": weekly_sessions,
        }