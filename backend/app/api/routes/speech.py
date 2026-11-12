"""
Speech recognition (ASR) endpoint.
"""

from pathlib import Path

from fastapi import APIRouter, File, Form, Request, UploadFile
from loguru import logger

from app.core.config import settings
from app.core.exceptions import FileTooLargeError, InvalidFormatError
from app.core.limiter import limiter
from app.schemas.speech import TranscribeResponse
from app.services.speech import speech_service

router = APIRouter(prefix="/speech", tags=["Speech Recognition"])


@router.post(
    "/transcribe",
    response_model=TranscribeResponse,
    summary="Transcribe speech to text",
    description=(
        "Upload an audio recording (max 30 s). The server runs Whisper "
        "and returns the transcript with detected language."
    ),
)
@limiter.limit(settings.RATE_LIMIT_SPEECH)
async def transcribe_speech(
    request: Request,
    audio: UploadFile = File(..., description="Audio file (.wav, .mp3, .m4a, .webm)"),
    language: str = Form("en", description="Language hint: en, hi, mr"),
) -> TranscribeResponse:
    # ── Validate format ───────────────────────────────────
    ext = Path(audio.filename or "").suffix.lower()
    if ext not in settings.SUPPORTED_AUDIO_FORMATS:
        raise InvalidFormatError(
            f"Unsupported audio format '{ext}'. "
            f"Accepted: {', '.join(settings.SUPPORTED_AUDIO_FORMATS)}"
        )

    # ── Validate size ─────────────────────────────────────
    audio_bytes = await audio.read()
    max_bytes = settings.MAX_AUDIO_SIZE_MB * 1024 * 1024
    if len(audio_bytes) > max_bytes:
        raise FileTooLargeError(settings.MAX_AUDIO_SIZE_MB)

    # ── Validate language ─────────────────────────────────
    lang_hint = language if language in settings.SUPPORTED_LANGUAGES else None

    # ── Transcribe ────────────────────────────────────────
    result = await speech_service.transcribe(audio_bytes, lang_hint)
    return result
