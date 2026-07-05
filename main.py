from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import engine
import models
from routes import (auth_routes, exercise_routes,
                    analyze_routes, session_routes)

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="FitTrack BI API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_routes.router)
app.include_router(exercise_routes.router)
app.include_router(analyze_routes.router)
app.include_router(session_routes.router)

@app.get("/")
def root():
    return {"message": "FitTrack BI API is running"}