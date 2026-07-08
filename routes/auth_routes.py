from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models import User
from schemas import RegisterRequest, LoginRequest, UpdateProfileRequest
from auth import hash_password, verify_password, create_token
from datetime import datetime, timedelta

router = APIRouter(prefix="/auth", tags=["auth"])

# ---------------- REGISTER ---------------- #

@router.post("/register", status_code=201)
def register(req: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == req.email).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Email already exists"
        )

    user = User(
        name=req.name,
        email=req.email,
        password=hash_password(req.password)
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_token({
        "user_id": user.id,
        "email": user.email,
        "role": user.role
    })

    return {
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "token": token
    }

# ---------------- LOGIN ---------------- #

@router.post("/login")
def login(req: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == req.email).first()

    if not user:
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )

    # Check if account is locked
    if user.locked_until and user.locked_until > datetime.utcnow():
        remaining = int(
            (user.locked_until - datetime.utcnow()).total_seconds() / 60
        )

        raise HTTPException(
            status_code=403,
            detail=f"Account locked. Try again in {remaining} minutes"
        )

    # Wrong password
    if not verify_password(req.password, user.password):

        user.failed_attempts = (user.failed_attempts or 0) + 1

        if user.failed_attempts >= 5:
            user.locked_until = datetime.utcnow() + timedelta(minutes=5)
            user.failed_attempts = 0
            db.commit()

            raise HTTPException(
                status_code=403,
                detail="Too many failed attempts. Account locked for 5 minutes"
            )

        db.commit()

        remaining = 5 - user.failed_attempts

        raise HTTPException(
            status_code=401,
            detail=f"Invalid credentials. {remaining} attempts remaining"
        )

    # Successful login
    user.failed_attempts = 0
    user.locked_until = None
    db.commit()

    token = create_token({
        "user_id": user.id,
        "email": user.email,
        "role": user.role
    })

    return {
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role,
        "token": token
    }

# ---------------- GET PROFILE ---------------- #

@router.get("/profile/{user_id}")
def get_profile(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    return {
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "age": user.age,
        "height": user.height,
        "weight": user.weight,
        "gender": user.gender,
    }


# ---------------- UPDATE PROFILE ---------------- #

@router.put("/profile/{user_id}")
def update_profile(
    user_id: int,
    req: UpdateProfileRequest,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == user_id).first()

    print(user.email, user.role)
    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

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

    db.commit()
    db.refresh(user)

    return {
        "user_id": user.id,
        "name": user.name,
        "email": user.email,
        "age": user.age,
        "height": user.height,
        "weight": user.weight,
        "gender": user.gender,
    }