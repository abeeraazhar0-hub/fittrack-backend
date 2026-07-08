from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from database import get_db
from models import User, Exercise
from schemas import AdminCreateUserRequest, AdminUpdateUserRequest
from auth import hash_password

router = APIRouter(
    prefix="/admin",
    tags=["admin"]
)


# ---------------- GET ALL USERS ---------------- #

@router.get("/users")
def get_all_users(db: Session = Depends(get_db)):
    users = db.query(User).all()

    return [
        {
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "role": user.role
        }
        for user in users
    ]


# ---------------- GET ALL EXERCISES ---------------- #
# ---------------- GET ALL EXERCISES ---------------- #

@router.get("/exercises")
def get_all_exercises(
    db: Session = Depends(get_db)
):
    exercises = db.query(Exercise).all()

    return [
        {
            "exercise_id": e.id,
            "name": e.name,
            "description": e.description,
            "category": e.category.name if e.category else "",
            "is_active": e.is_active
        }
        for e in exercises
    ]

# ---------------- TOGGLE EXERCISE STATUS ---------------- #

@router.put("/exercises/{exercise_id}/toggle")
def toggle_exercise(
    exercise_id: int,
    db: Session = Depends(get_db)
):

    exercise = db.query(Exercise).filter(
        Exercise.id == exercise_id
    ).first()

    if not exercise:
        raise HTTPException(
            status_code=404,
            detail="Exercise not found"
        )

    exercise.is_active = not exercise.is_active

    db.commit()
    db.refresh(exercise)

    return {
        "exercise_id": exercise.id,
        "is_active": exercise.is_active
    }
# ---------------- VIEW REPORTS ---------------- #

@router.get("/reports")
def view_reports():
    return {
        "message": "Reports endpoint working"
    }
# ---------------- ADD USER ---------------- #

@router.post("/users", status_code=201)
def add_user(
    req: AdminCreateUserRequest,
    db: Session = Depends(get_db)
):

    existing = db.query(User).filter(
        User.email == req.email
    ).first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Email already exists"
        )

    user = User(
        name=req.name,
        email=req.email,
        password=hash_password(req.password),
        role=req.role
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role
    }
# ---------------- UPDATE USER ---------------- #

@router.put("/users/{user_id}")
def update_user(
    user_id: int,
    req: AdminUpdateUserRequest,
    db: Session = Depends(get_db)
):

    user = db.query(User).filter(
        User.id == user_id
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    if req.name is not None:
        user.name = req.name

    if req.email is not None:
        user.email = req.email

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

    if req.role is not None:
        user.role = req.role


    db.commit()
    db.refresh(user)

    return {
        "message": "User updated successfully"
    }
# ---------------- DELETE USER ---------------- #

@router.delete("/users/{user_id}")
def delete_user(
    user_id: int,
    db: Session = Depends(get_db)
):

    user = db.query(User).filter(
        User.id == user_id
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    db.delete(user)
    db.commit()

    return {
        "message": "User deleted successfully"
    }