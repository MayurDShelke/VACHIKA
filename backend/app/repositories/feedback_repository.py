"""
Feedback data repository — Supabase data access layer.
"""

import uuid
from datetime import datetime, timezone

from loguru import logger

from app.core.supabase import get_supabase_client


class FeedbackRepository:
    """Data access for the `feedback` table."""

    async def create(self, feedback: dict) -> dict:
        """Insert a feedback record."""
        try:
            client = get_supabase_client()
            fb_id = f"fb_{uuid.uuid4().hex[:12]}"
            now = datetime.now(timezone.utc).isoformat()

            data = {
                "feedback_id": fb_id,
                "type": feedback["type"],
                "predicted_gloss": feedback.get("predicted_gloss"),
                "corrected_gloss": feedback.get("corrected_gloss"),
                "predicted_text": feedback.get("predicted_text"),
                "corrected_text": feedback.get("corrected_text"),
                "context": feedback.get("context"),
                "conversation_id": feedback.get("conversation_id"),
                "comment": feedback.get("comment"),
                "created_at": now,
            }

            client.table("feedback").insert(data).execute()
            return {
                "feedback_id": fb_id,
                "type": feedback["type"],
                "created_at": now,
            }

        except Exception as e:
            logger.error(f"Failed to create feedback: {e}")
            raise
