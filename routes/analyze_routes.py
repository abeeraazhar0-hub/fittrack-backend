from fastapi import APIRouter
from schemas import AnalyzeRequest, AnalyzeResponse
from ai.pose_analyzer import analyze_frame

router = APIRouter(prefix="/analyze", tags=["analyze"])

@router.post("/")
def analyze(req: AnalyzeRequest):
    status, message, reps, accuracy = analyze_frame(
        req.frame_base64,
        req.exercise_id,
        req.session_id
    )
    return {
        "posture_status": status,
        "feedback_message": message,
        "rep_count": reps,
        "accuracy_percent": accuracy
    }
