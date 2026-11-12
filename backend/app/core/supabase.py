"""
Supabase client singleton.
"""

from supabase import create_client, Client
from app.core.config import settings

_client: Client | None = None


def get_supabase_client() -> Client:
    """Return the Supabase client, creating it on first call."""
    global _client
    if _client is None:
        if not settings.SUPABASE_URL or not settings.SUPABASE_KEY:
            raise RuntimeError(
                "SUPABASE_URL and SUPABASE_KEY must be set in environment."
            )
        _client = create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
    return _client
