"""
Sign dictionary service.
"""

from loguru import logger

from app.core.exceptions import NotFoundError
from app.repositories.sign_repository import SignRepository
from app.schemas.signs import SignDetail, SignListResponse, SignSummary


class SignDictionaryService:
    """Business logic for browsing and searching the sign dictionary."""

    def __init__(self) -> None:
        self.sign_repo = SignRepository()

    async def list_signs(
        self,
        category: str | None = None,
        search: str | None = None,
        language: str = "en",
        page: int = 1,
        page_size: int = 20,
    ) -> SignListResponse:
        """List signs with optional filtering and pagination."""
        page_size = min(page_size, 50)  # Cap at 50
        offset = (page - 1) * page_size

        rows, total = await self.sign_repo.list_signs(
            category=category,
            search=search,
            language=language,
            limit=page_size,
            offset=offset,
        )

        signs = [
            SignSummary(
                sign_id=row["sign_id"],
                gloss=row["gloss"],
                label=row.get("labels", {}).get(language, row["gloss"]),
                category=row.get("category", ""),
                video_url=row.get("video_url", ""),
                verified=row.get("verified", False),
            )
            for row in rows
        ]

        return SignListResponse(
            signs=signs,
            total=total,
            page=page,
            page_size=page_size,
        )

    async def get_sign(self, sign_id: str) -> SignDetail:
        """Get full details of a single sign including variants."""
        sign = await self.sign_repo.get_by_id(sign_id)
        if not sign:
            raise NotFoundError("Sign", sign_id)

        variants = await self.sign_repo.get_variants(sign_id)

        return SignDetail(
            sign_id=sign["sign_id"],
            gloss=sign["gloss"],
            labels=sign.get("labels", {}),
            category=sign.get("category", ""),
            description=sign.get("description", ""),
            video_url=sign.get("video_url", ""),
            verified=sign.get("verified", False),
            variants=[
                {
                    "variant_id": v["variant_id"],
                    "region": v["region"],
                    "video_url": v["video_url"],
                    "verified": v["verified"],
                }
                for v in variants
            ],
        )


# Module-level singleton
sign_dictionary_service = SignDictionaryService()
