"""
Conversation endpoints.
"""

from fastapi import APIRouter, Request
from fastapi.responses import Response

from app.core.config import settings
from app.core.limiter import limiter
from app.schemas.conversation import (
    ConversationCreate,
    ConversationOut,
    MessageCreate,
    MessageOut,
)
from app.services.conversation import conversation_service

router = APIRouter(prefix="/conversations", tags=["Conversations"])


@router.post(
    "",
    response_model=ConversationOut,
    status_code=201,
    summary="Create conversation",
    description="Start a new conversation session for Conversation Mode.",
)
@limiter.limit(settings.RATE_LIMIT_CONVERSATIONS)
async def create_conversation(
    request: Request, body: ConversationCreate
) -> ConversationOut:
    return await conversation_service.create_conversation(body)


@router.get(
    "/{conversation_id}",
    response_model=ConversationOut,
    summary="Get conversation",
    description="Retrieve a conversation with its full message history.",
)
@limiter.limit(settings.RATE_LIMIT_CONVERSATIONS)
async def get_conversation(
    request: Request, conversation_id: str
) -> ConversationOut:
    return await conversation_service.get_conversation(conversation_id)


@router.post(
    "/{conversation_id}/messages",
    response_model=MessageOut,
    status_code=201,
    summary="Add message",
    description="Append a message (turn) to a conversation.",
)
@limiter.limit(settings.RATE_LIMIT_CONVERSATIONS)
async def add_message(
    request: Request, conversation_id: str, body: MessageCreate
) -> MessageOut:
    return await conversation_service.add_message(conversation_id, body)


@router.delete(
    "/{conversation_id}",
    status_code=204,
    summary="Delete conversation",
    description="Delete a conversation and all its messages.",
)
@limiter.limit(settings.RATE_LIMIT_CONVERSATIONS)
async def delete_conversation(
    request: Request, conversation_id: str
) -> Response:
    await conversation_service.delete_conversation(conversation_id)
    return Response(status_code=204)
