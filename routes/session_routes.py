from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import WorkoutSession
from schemas import StartSessionRequest, StartSessionResponse, EndSessionRequest, EndSessionResponse
from datetime import datetime

router = APIRouter(prefix="/sessions", tags=["sessions"])

@router.post("/start", status_code=201)
def start_session(req: StartSessionRequest, db: Session = Depends(get_db)):
    session = WorkoutSession(user_id=req.user_id, exercise_id=req.exercise_id)
    db.add(session)
    db.commit()
    db.refresh(session)
    return {"session_id": session.id, "start_time": session.start_time.isoformat()}

@router.get("/history/{user_id}")
def get_history(user_id: int, db: Session = Depends(get_db)):
    sessions = db.query(WorkoutSession).filter(WorkoutSession.user_id == user_id).all()
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
