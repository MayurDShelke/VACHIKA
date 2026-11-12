"""
Translation endpoint schemas.
"""

from pydantic import BaseModel, Field


# ── Text → Sign ───────────────────────────────────────────────


class TextToSignRequest(BaseModel):
    text: str = Field(..., max_length=500)
    source_language: str = "en"


class SignMatch(BaseModel):
    token: str
    sign_id: str | None = None
    gloss: str | None = None
    video_url: str | None = None
    available: bool


class TextToSignResponse(BaseModel):
    input_text: str
    tokens: list[str]
    signs: list[SignMatch]
    coverage: float = Field(..., ge=0.0, le=1.0)
    unavailable_words: list[str]


# ── Gloss → Text ─────────────────────────────────────────────


class GlossToTextRequest(BaseModel):
    gloss: str
    target_language: str = "en"


class GlossToTextResponse(BaseModel):
    gloss: str
    text: str
    language: str
