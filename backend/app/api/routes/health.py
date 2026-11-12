"""
Health check endpoint.
"""

from datetime import datetime, timezone

from fastapi import APIRouter

from app.core.config import settings
from app.schemas.health import HealthResponse

router = APIRouter(tags=["Health"])


@router.get(
    "/health",
    response_model=HealthResponse,
    summary="Health check",
    description="Returns server status, loaded model version, and Whisper model name.",
)
async def health_check() -> HealthResponse:
    return HealthResponse(
        status="ok",
        model_version=settings.MODEL_VERSION,
        whisper_model=settings.WHISPER_MODEL_SIZE,
        timestamp=datetime.now(timezone.utc).isoformat(),
    )
