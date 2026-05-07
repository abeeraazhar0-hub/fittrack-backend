from fastapi import FastAPI
from database import engine
import models

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

from routes import auth_routes, exercise_routes, analyze_routes, session_routes

app.include_router(auth_routes.router)
app.include_router(exercise_routes.router)
app.include_router(analyze_routes.router)
app.include_router(session_routes.router)

@app.get("/")
def root():
    return {"message": "FitTrack API is running!"}
