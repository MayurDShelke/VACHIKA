"""
Conversation endpoint schemas.
"""

from pydantic import BaseModel


# ── Messages ──────────────────────────────────────────────────


class MessageSignRef(BaseModel):
    gloss: str
    available: bool
    video_url: str | None = None


class MessageOut(BaseModel):
    message_id: str
    participant: str  # "deaf" | "hearing"
    direction: str  # "sign_to_text" | "text_to_sign"
    gloss: str | None = None
    text: str
    signs: list[MessageSignRef] | None = None
    timestamp: str


class MessageCreate(BaseModel):
    participant: str
    direction: str
    gloss: str | None = None
    text: str
    signs: list[MessageSignRef] | None = None


# ── Conversations ─────────────────────────────────────────────


class ConversationCreate(BaseModel):
    language: str = "en"


class ConversationOut(BaseModel):
    conversation_id: str
    language: str
    created_at: str
    messages: list[MessageOut] = []
