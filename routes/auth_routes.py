from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User
from schemas import RegisterRequest, LoginRequest, UpdateProfileRequest
from auth import hash_password, verify_password, create_token

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", status_code=201)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(
        User.email == req.email).first()
    if existing:
        raise HTTPException(
            status_code=400, detail="Email already exists")
    user = User(
        name=req.name,
        email=req.email,
        password=hash_password(req.password)
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    token = create_token(
        {"user_id": user.id, "email": user.email})
    return {
        "user_id": user.id,
        "name": user.name,
        "token": token
    }

@router.post("/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(
        User.email == req.email).first()
    if not user or not verify_password(
            req.password, user.password):
        raise HTTPException(
            status_code=401, detail="Invalid credentials")
    token = create_token(
        {"user_id": user.id, "email": user.email})
    return {
        "user_id": user.id,
        "name": user.name,
        "token": token
    }

@router.get("/profile/{user_id}")
def get_profile(
    user_id: int,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(
        User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=404, detail="User not found")
    return {
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "age": user.age,
        "height": user.height,
        "weight": user.weight,
        "gender": user.gender,
        "fitness_goal": user.fitness_goal
    }

@router.put("/profile/{user_id}")
def update_profile(
    user_id: int,
    req: UpdateProfileRequest,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(
        User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=404, detail="User not found")
    if req.name is not None:
        user.name = req.name
    if req.age is not None:
        user.age = req.age
    if req.height is not None:
        user.height = req.height
    if req.weight is not None:
        user.weight = req.weight
    if req.gender is not None:
        user.gender = req.gender
    if req.fitness_goal is not None:
        user.fitness_goal = req.fitness_goal
    db.commit()
    return {
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "age": user.age,
        "height": user.height,
        "weight": user.weight,
        "gender": user.gender,
        "fitness_goal": user.fitness_goal
    }