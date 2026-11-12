"""
Health endpoint schemas.
"""

from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str = "ok"
    model_version: str
    whisper_model: str
    timestamp: str
