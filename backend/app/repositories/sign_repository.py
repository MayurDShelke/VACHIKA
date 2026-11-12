"""
Sign data repository — Supabase data access layer.
"""

from loguru import logger

from app.core.supabase import get_supabase_client


class SignRepository:
    """
    Data access for the `signs` and `sign_variants` tables.
    All methods return plain dicts; the service layer converts to Pydantic models.
    """

    # ── Read ──────────────────────────────────────────────────

    async def list_signs(
        self,
        category: str | None = None,
        search: str | None = None,
        language: str = "en",
        limit: int = 20,
        offset: int = 0,
    ) -> tuple[list[dict], int]:
        """
        List signs with optional category/search filters and pagination.
        Returns (rows, total_count).
        """
        try:
            client = get_supabase_client()
            query = client.table("signs").select("*", count="exact")

            if category:
                query = query.eq("category", category)
            if search:
                # Search across the JSONB labels column (all languages)
                query = query.or_(
                    f"gloss.ilike.%{search}%,"
                    f"labels->>en.ilike.%{search}%,"
                    f"labels->>hi.ilike.%{search}%,"
                    f"labels->>mr.ilike.%{search}%"
                )

            result = query.range(offset, offset + limit - 1).execute()
            return result.data or [], result.count or 0

        except Exception as e:
            logger.error(f"Failed to list signs: {e}")
            return [], 0

    async def get_by_id(self, sign_id: str) -> dict | None:
        """Get a single sign by ID."""
        try:
            client = get_supabase_client()
            result = (
                client.table("signs")
                .select("*")
                .eq("sign_id", sign_id)
                .maybe_single()
                .execute()
            )
            return result.data
        except Exception as e:
            logger.error(f"Failed to get sign {sign_id}: {e}")
            return None

    async def find_by_gloss(self, gloss: str) -> dict | None:
        """Find a sign by its canonical gloss."""
        try:
            client = get_supabase_client()
            result = (
                client.table("signs")
                .select("*")
                .eq("gloss", gloss.upper())
                .maybe_single()
                .execute()
            )
            return result.data
        except Exception as e:
            logger.error(f"Failed to find gloss '{gloss}': {e}")
            return None

    async def find_by_label(self, label: str, language: str = "en") -> dict | None:
        """Find a sign by its label text in a given language."""
        try:
            client = get_supabase_client()
            # Query the JSONB labels field: labels->>en = 'hello'
            result = (
                client.table("signs")
                .select("*")
                .ilike(f"labels->>{language}", label)
                .maybe_single()
                .execute()
            )
            return result.data
        except Exception as e:
            logger.error(f"Failed to find label '{label}' ({language}): {e}")
            return None

    async def get_variants(self, sign_id: str) -> list[dict]:
        """Get all verified variants for a sign."""
        try:
            client = get_supabase_client()
            result = (
                client.table("sign_variants")
                .select("*")
                .eq("sign_id", sign_id)
                .execute()
            )
            return result.data or []
        except Exception as e:
            logger.error(f"Failed to get variants for {sign_id}: {e}")
            return []
