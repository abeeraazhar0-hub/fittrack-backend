from pydantic import BaseModel
from typing import Optional

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

class AnalyzeResponse(BaseModel):
    posture_status: str
    feedback_message: str
    rep_count: int
    accuracy_percent: float
class UpdateProfileRequest(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    gender: Optional[str] = None
    fitness_goal: Optional[str] = None

class StartSessionRequest(BaseModel):
    user_id: int
    exercise_id: int

class EndSessionRequest(BaseModel):
    session_id: int

class AnalyzeRequest(BaseModel):
    frame_base64: str
    exercise_id: int
    session_id: int
class AdminCreateUserRequest(BaseModel):
    name: str
    email: str
    password: str
    role: Optional[str] = "user"


class AdminUpdateUserRequest(BaseModel):
    name: Optional[str] = None
    email: Optional[str] = None
    age: Optional[int] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    gender: Optional[str] = None
    fitness_goal: Optional[str] = None
    role: Optional[str] = None