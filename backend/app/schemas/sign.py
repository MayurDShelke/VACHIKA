"""
Sign recognition endpoint schemas.
"""

from pydantic import BaseModel, Field


class Prediction(BaseModel):
    rank: int = Field(..., ge=1, le=3)
    gloss: str
    label: str
    confidence: float = Field(..., ge=0.0, le=1.0)


class SignRecognizeResponse(BaseModel):
    predictions: list[Prediction]
    is_confident: bool
    threshold: float
    model_version: str
    processing_time_ms: int
