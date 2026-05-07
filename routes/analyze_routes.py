from fastapi import APIRouter

router = APIRouter(prefix="/analyze", tags=["analyze"])

@router.get("/")
def analyze():
    return {"message": "Analyze route working"}
