from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import WorkoutSession, Feedback
from schemas import AnalyzeRequest, AnalyzeResponse
from ai.pose_analyzer import analyze_frame, rep_state

router = APIRouter(prefix="/analyze", tags=["analyze"])

@router.post("/", response_model=AnalyzeResponse)
def analyze(req: AnalyzeRequest, db: Session = Depends(get_db)):
    status, message, rep_count, accuracy = analyze_frame(
        req.frame_base64, req.exercise_id, req.session_id
    )

    print("DEBUG session_id=" + str(req.session_id) + " rep_count=" + str(rep_count))
    print("DEBUG rep_state=" + str(rep_state.get(req.session_id)))

    session = db.query(WorkoutSession).filter(
        WorkoutSession.id == req.session_id
    ).first()

    if session:
        session.total_reps = rep_count
        session.accuracy_percent = accuracy
        state = rep_state.get(req.session_id, {})
        session.correct_reps = state.get("correct", 0)
        db.commit()
        print("DEBUG saved total_reps=" + str(session.total_reps))

    feedback = Feedback(
        session_id=req.session_id,
        posture_status=status,
        message=message
    )
    db.add(feedback)
    db.commit()

    return {
        "posture_status": status,
        "feedback_message": message,
        "rep_count": rep_count,
        "accuracy_percent": accuracy
    }
