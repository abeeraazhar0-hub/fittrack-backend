from database import SessionLocal
from models import ExerciseCategory, Exercise

db = SessionLocal()

legs = ExerciseCategory(name="Legs", description="Lower body exercises")
upper = ExerciseCategory(name="Upper Body", description="Upper body exercises")
core = ExerciseCategory(name="Core", description="Core strength exercises")
db.add_all([legs, upper, core])
db.commit()

exercises = [
    Exercise(name="Squat", description="Bend knees to 90 degrees", category_id=legs.id),
    Exercise(name="Push-up", description="Lower chest to floor", category_id=upper.id),
    Exercise(name="Plank", description="Hold straight body position", category_id=core.id),
]
db.add_all(exercises)
db.commit()
db.close()
print("Database seeded successfully!")
