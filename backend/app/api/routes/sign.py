"""
Sign recognition endpoint.
"""

from pathlib import Path

from fastapi import APIRouter, File, Form, Request, UploadFile
from loguru import logger

from app.core.config import settings
from app.core.exceptions import FileTooLargeError, InvalidFormatError
from app.core.limiter import limiter
from app.schemas.sign import SignRecognizeResponse
from app.services.sign_inference import sign_inference_service

router = APIRouter(prefix="/sign", tags=["Sign Recognition"])


@router.post(
    "/recognize",
    response_model=SignRecognizeResponse,
    summary="Recognize ISL sign from video clip",
    description=(
        "Upload a 2–5 second video clip. The server extracts landmarks, "
        "runs the recognition model, and returns top-3 predictions."
    ),
)
@limiter.limit(settings.RATE_LIMIT_SIGN)
async def recognize_sign(
    request: Request,
    clip: UploadFile = File(..., description="Video clip (.mp4, .webm, .mov)"),
    language: str = Form("en", description="Label language: en, hi, mr"),
) -> SignRecognizeResponse:
    # ── Validate format ───────────────────────────────────
    ext = Path(clip.filename or "").suffix.lower()
    if ext not in settings.SUPPORTED_CLIP_FORMATS:
        raise InvalidFormatError(
            f"Unsupported file type '{ext}'. "
            f"Accepted: {', '.join(settings.SUPPORTED_CLIP_FORMATS)}"
        )

    # ── Validate size ─────────────────────────────────────
    clip_bytes = await clip.read()
    max_bytes = settings.MAX_CLIP_SIZE_MB * 1024 * 1024
    if len(clip_bytes) > max_bytes:
        raise FileTooLargeError(settings.MAX_CLIP_SIZE_MB)

    # ── Validate language ─────────────────────────────────
    if language not in settings.SUPPORTED_LANGUAGES:
        language = "en"

    # ── Run inference ─────────────────────────────────────
    result = await sign_inference_service.recognize(clip_bytes, language)
    return result
