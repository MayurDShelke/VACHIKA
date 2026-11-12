"""
Conversation management service.
"""

from loguru import logger

from app.core.exceptions import NotFoundError
from app.repositories.conversation_repository import ConversationRepository
from app.schemas.conversation import (
    ConversationCreate,
    ConversationOut,
    MessageCreate,
    MessageOut,
)


class ConversationService:
    """CRUD logic for conversations and messages."""

    def __init__(self) -> None:
        self.repo = ConversationRepository()

    async def create_conversation(
        self, data: ConversationCreate
    ) -> ConversationOut:
        """Create a new conversation session."""
        conv = await self.repo.create(data.language)
        return ConversationOut(**conv)

    async def get_conversation(self, conversation_id: str) -> ConversationOut:
        """Retrieve a conversation with all messages."""
        conv = await self.repo.get_by_id(conversation_id)
        if not conv:
            raise NotFoundError("Conversation", conversation_id)
        return ConversationOut(**conv)

    async def add_message(
        self, conversation_id: str, data: MessageCreate
    ) -> MessageOut:
        """Add a message to a conversation."""
        # Ensure conversation exists
        conv = await self.repo.get_by_id(conversation_id)
        if not conv:
            raise NotFoundError("Conversation", conversation_id)

        msg = await self.repo.add_message(conversation_id, data.model_dump())
        return MessageOut(**msg)

    async def delete_conversation(self, conversation_id: str) -> None:
        """Delete a conversation and its messages."""
        conv = await self.repo.get_by_id(conversation_id)
        if not conv:
            raise NotFoundError("Conversation", conversation_id)
        await self.repo.delete(conversation_id)


# Module-level singleton
conversation_service = ConversationService()
