"""
Sign dictionary endpoints.
"""

from fastapi import APIRouter, Query, Request

from app.core.config import settings
from app.core.limiter import limiter
from app.schemas.signs import SignDetail, SignListResponse
from app.services.sign_dictionary import sign_dictionary_service

router = APIRouter(prefix="/signs", tags=["Dictionary"])


@router.get(
    "",
    response_model=SignListResponse,
    summary="List signs",
    description="Browse and search the sign dictionary with optional filters.",
)
@limiter.limit(settings.RATE_LIMIT_DICTIONARY)
async def list_signs(
    request: Request,
    category: str | None = Query(None, description="Filter by category"),
    search: str | None = Query(None, description="Search labels in all languages"),
    language: str = Query("en", description="Language for returned labels"),
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(20, ge=1, le=50, description="Items per page"),
) -> SignListResponse:
    return await sign_dictionary_service.list_signs(
        category=category,
        search=search,
        language=language,
        page=page,
        page_size=page_size,
    )


@router.get(
    "/{sign_id}",
    response_model=SignDetail,
    summary="Get sign details",
    description="Retrieve full details for a sign including all language labels and regional variants.",
)
@limiter.limit(settings.RATE_LIMIT_DICTIONARY)
async def get_sign(request: Request, sign_id: str) -> SignDetail:
    return await sign_dictionary_service.get_sign(sign_id)
