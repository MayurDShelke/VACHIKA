"""
Conversation data repository — Supabase data access layer.
"""

import uuid
from datetime import datetime, timezone

from loguru import logger

from app.core.supabase import get_supabase_client


class ConversationRepository:
    """Data access for `conversations` and `messages` tables."""

    # ── Conversations ─────────────────────────────────────────

    async def create(self, language: str) -> dict:
        """Create a new conversation."""
        try:
            client = get_supabase_client()
            conv_id = f"conv_{uuid.uuid4().hex[:12]}"
            now = datetime.now(timezone.utc).isoformat()

            data = {
                "conversation_id": conv_id,
                "language": language,
                "created_at": now,
            }
            client.table("conversations").insert(data).execute()

            return {**data, "messages": []}

        except Exception as e:
            logger.error(f"Failed to create conversation: {e}")
            raise

    async def get_by_id(self, conversation_id: str) -> dict | None:
        """Get a conversation with its messages."""
        try:
            client = get_supabase_client()

            # Fetch conversation
            conv_result = (
                client.table("conversations")
                .select("*")
                .eq("conversation_id", conversation_id)
                .maybe_single()
                .execute()
            )
            if not conv_result.data:
                return None

            # Fetch messages
            msg_result = (
                client.table("messages")
                .select("*")
                .eq("conversation_id", conversation_id)
                .order("timestamp", desc=False)
                .execute()
            )

            conv = conv_result.data
            conv["messages"] = msg_result.data or []
            return conv

        except Exception as e:
            logger.error(f"Failed to get conversation {conversation_id}: {e}")
            return None

    async def add_message(self, conversation_id: str, message: dict) -> dict:
        """Add a message to a conversation."""
        try:
            client = get_supabase_client()
            msg_id = f"msg_{uuid.uuid4().hex[:12]}"
            now = datetime.now(timezone.utc).isoformat()

            data = {
                "message_id": msg_id,
                "conversation_id": conversation_id,
                "participant": message["participant"],
                "direction": message["direction"],
                "gloss": message.get("gloss"),
                "text": message["text"],
                "signs": message.get("signs"),
                "timestamp": now,
            }

            client.table("messages").insert(data).execute()
            return data

        except Exception as e:
            logger.error(f"Failed to add message to {conversation_id}: {e}")
            raise

    async def delete(self, conversation_id: str) -> None:
        """Delete a conversation and all its messages."""
        try:
            client = get_supabase_client()
            # Delete messages first (FK)
            client.table("messages").delete().eq(
                "conversation_id", conversation_id
            ).execute()
            # Delete conversation
            client.table("conversations").delete().eq(
                "conversation_id", conversation_id
            ).execute()

        except Exception as e:
            logger.error(f"Failed to delete conversation {conversation_id}: {e}")
            raise
