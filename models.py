from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from database import Base
from sqlalchemy import Boolean

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    age = Column(Integer, nullable=True)
    height = Column(Float, nullable=True)
    weight = Column(Float, nullable=True)
    gender = Column(String, nullable=True)
    fitness_goal = Column(String, nullable=True)
    failed_attempts = Column(Integer, default=0)
    locked_until = Column(DateTime, nullable=True)
    role = Column(String, default="user")
    sessions = relationship("WorkoutSession", back_populates="user")


class ExerciseCategory(Base):
    __tablename__ = "exercise_categories"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    description = Column(String)
    exercises = relationship("Exercise", back_populates="category")

class Exercise(Base):
    __tablename__ = "exercises"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    description = Column(String)
    category_id = Column(Integer, ForeignKey("exercise_categories.id"))
    is_active = Column(Boolean, default=True)
    category = relationship("ExerciseCategory", back_populates="exercises")

class WorkoutSession(Base):
    __tablename__ = "workout_sessions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    exercise_id = Column(Integer, ForeignKey("exercises.id"))
    start_time = Column(DateTime, default=datetime.utcnow)
    end_time = Column(DateTime, nullable=True)
    total_reps = Column(Integer, default=0)
    correct_reps = Column(Integer, default=0)
    accuracy_percent = Column(Float, default=0.0)
    duration_seconds = Column(Integer, default=0)
    user = relationship("User", back_populates="sessions")
    exercise = relationship("Exercise")
    feedbacks = relationship("Feedback", back_populates="session")

class Feedback(Base):
    __tablename__ = "feedbacks"
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("workout_sessions.id"))
    posture_status = Column(String)
    message = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow)
    session = relationship("WorkoutSession", back_populates="feedbacks")

