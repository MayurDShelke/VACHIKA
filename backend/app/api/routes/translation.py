"""
Translation endpoints: text-to-sign and gloss-to-text.
"""

from fastapi import APIRouter, Request

from app.core.config import settings
from app.core.limiter import limiter
from app.schemas.translation import (
    GlossToTextRequest,
    GlossToTextResponse,
    TextToSignRequest,
    TextToSignResponse,
)
from app.services.translation import translation_service

router = APIRouter(prefix="/translate", tags=["Translation"])


@router.post(
    "/text-to-sign",
    response_model=TextToSignResponse,
    summary="Convert text to ISL sign sequence",
    description=(
        "Tokenize and look up each word in the sign dictionary. "
        "Returns an ordered list of sign video URLs. "
        "Words without a verified sign are marked as unavailable."
    ),
)
@limiter.limit(settings.RATE_LIMIT_TRANSLATE)
async def text_to_sign(
    request: Request, body: TextToSignRequest
) -> TextToSignResponse:
    return await translation_service.text_to_sign(body)


@router.post(
    "/gloss-to-text",
    response_model=GlossToTextResponse,
    summary="Convert sign gloss to readable text",
    description=(
        "Given a canonical gloss label (e.g. THANK_YOU), "
        "return the human-readable text in the target language."
    ),
)
@limiter.limit(settings.RATE_LIMIT_TRANSLATE)
async def gloss_to_text(
    request: Request, body: GlossToTextRequest
) -> GlossToTextResponse:
    return await translation_service.gloss_to_text(body)
