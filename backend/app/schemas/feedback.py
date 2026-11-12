"""
Feedback endpoint schemas.
"""

from pydantic import BaseModel, Field


class FeedbackCreate(BaseModel):
    type: str  # "sign_correction" | "transcription_correction" | "general"
    predicted_gloss: str | None = None
    corrected_gloss: str | None = None
    predicted_text: str | None = None
    corrected_text: str | None = None
    context: str | None = None  # "sign_to_speech" | "speech_to_sign" | "conversation" | "dictionary"
    conversation_id: str | None = None
    comment: str | None = Field(None, max_length=500)


class FeedbackOut(BaseModel):
    feedback_id: str
    type: str
    created_at: str
