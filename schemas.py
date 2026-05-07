from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str

class LoginRequest(BaseModel):
    email: str
    password: str

class AuthResponse(BaseModel):
    user_id: int
    name: str
    token: str

class ExerciseOut(BaseModel):
    exercise_id: int
    name: str
    category: str
    description: str

class StartSessionRequest(BaseModel):
    user_id: int
    exercise_id: int

class StartSessionResponse(BaseModel):
    session_id: int
    start_time: str

class EndSessionRequest(BaseModel):
    session_id: int

class EndSessionResponse(BaseModel):
    total_reps: int
    correct_reps: int
    accuracy_percent: float
    duration_seconds: int

class AnalyzeRequest(BaseModel):
    frame_base64: str
    exercise_id: int
    session_id: int

class AnalyzeResponse(BaseModel):
    posture_status: str
    feedback_message: str
    rep_count: int
    accuracy_percent: float

class SessionHistoryItem(BaseModel):
    session_id: int
    exercise_name: str
    total_reps: int
    accuracy_percent: float
    duration_seconds: int
    start_time: str
