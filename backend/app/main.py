from fastapi import FastAPI
from app.api import auth, workouts
app = FastAPI(title="Health Tracker")
app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(workouts.router, prefix="/workouts", tags=["Workouts"])