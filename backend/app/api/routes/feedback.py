"""
Feedback endpoint.
"""

from fastapi import APIRouter, Request

from app.core.config import settings
from app.core.limiter import limiter
from app.repositories.feedback_repository import FeedbackRepository
from app.schemas.feedback import FeedbackCreate, FeedbackOut

router = APIRouter(prefix="/feedback", tags=["Feedback"])

_repo = FeedbackRepository()


@router.post(
    "",
    response_model=FeedbackOut,
    status_code=201,
    summary="Submit feedback",
    description="Submit a user correction for a sign prediction or transcription.",
)
@limiter.limit(settings.RATE_LIMIT_FEEDBACK)
async def submit_feedback(
    request: Request, body: FeedbackCreate
) -> FeedbackOut:
    result = await _repo.create(body.model_dump())
    return FeedbackOut(**result)
