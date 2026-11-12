"""
Sign dictionary endpoint schemas.
"""

from pydantic import BaseModel


class SignVariant(BaseModel):
    variant_id: str
    region: str
    video_url: str
    verified: bool


class SignSummary(BaseModel):
    sign_id: str
    gloss: str
    label: str
    category: str
    video_url: str
    verified: bool


class SignDetail(BaseModel):
    sign_id: str
    gloss: str
    labels: dict[str, str]  # {"en": "...", "hi": "...", "mr": "..."}
    category: str
    description: str
    video_url: str
    verified: bool
    variants: list[SignVariant] = []


class SignListResponse(BaseModel):
    signs: list[SignSummary]
    total: int
    page: int
    page_size: int
