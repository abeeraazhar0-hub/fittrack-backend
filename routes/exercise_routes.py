from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import Exercise

router = APIRouter(prefix="/exercises", tags=["exercises"])

@router.get("/")
def get_exercises(db: Session = Depends(get_db)):
    exercises = db.query(Exercise).all()
    return [
        {
            "exercise_id": e.id,
            "name": e.name,
            "category": e.category.name if e.category else "",
            "description": e.description
        }
        for e in exercises
    ]
