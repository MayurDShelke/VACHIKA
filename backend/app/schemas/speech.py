"""
Speech recognition endpoint schemas.
"""

from pydantic import BaseModel, Field


class TranscribeResponse(BaseModel):
    transcript: str
    language_detected: str
    confidence: float = Field(..., ge=0.0, le=1.0)
    processing_time_ms: int
