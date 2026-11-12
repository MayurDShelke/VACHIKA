"""
Translation service: Text → Sign sequence and Gloss → Text.
"""

import re
from loguru import logger

from app.core.exceptions import NotFoundError
from app.schemas.translation import (
    GlossToTextRequest,
    GlossToTextResponse,
    SignMatch,
    TextToSignRequest,
    TextToSignResponse,
)
from app.repositories.sign_repository import SignRepository


class TranslationService:
    """Handles text-to-ISL lookup and gloss-to-text conversion."""

    def __init__(self) -> None:
        self.sign_repo = SignRepository()

    async def text_to_sign(self, request: TextToSignRequest) -> TextToSignResponse:
        """
        Normalize and tokenize input text, then look up each token
        in the sign dictionary. Returns an ordered sequence of sign
        matches with video URLs.
        """
        tokens = self._tokenize(request.text, request.source_language)

        signs: list[SignMatch] = []
        unavailable: list[str] = []

        for token in tokens:
            sign = await self.sign_repo.find_by_label(
                token, request.source_language
            )
            if sign:
                signs.append(
                    SignMatch(
                        token=token,
                        sign_id=sign["sign_id"],
                        gloss=sign["gloss"],
                        video_url=sign["video_url"],
                        available=True,
                    )
                )
            else:
                signs.append(
                    SignMatch(
                        token=token,
                        sign_id=None,
                        gloss=None,
                        video_url=None,
                        available=False,
                    )
                )
                unavailable.append(token)

        total = len(tokens)
        coverage = (total - len(unavailable)) / total if total > 0 else 0.0

        return TextToSignResponse(
            input_text=request.text,
            tokens=tokens,
            signs=signs,
            coverage=round(coverage, 4),
            unavailable_words=unavailable,
        )

    async def gloss_to_text(
        self, request: GlossToTextRequest
    ) -> GlossToTextResponse:
        """Convert a canonical gloss to human-readable text in the target language."""
        sign = await self.sign_repo.find_by_gloss(request.gloss)
        if not sign:
            raise NotFoundError("Gloss", request.gloss)

        labels = sign.get("labels", {})
        text = labels.get(request.target_language, labels.get("en", request.gloss))

        return GlossToTextResponse(
            gloss=request.gloss,
            text=text,
            language=request.target_language,
        )

    # ── Internals ─────────────────────────────────────────────

    def _tokenize(self, text: str, language: str) -> list[str]:
        """
        Normalize and tokenize text into words/phrases for dictionary lookup.
        MVP: lowercase, strip punctuation, split on whitespace.
        Future: lemmatization, multi-word phrase matching.
        """
        text = text.lower().strip()
        text = re.sub(r"[^\w\s]", "", text)  # remove punctuation
        tokens = text.split()
        # Remove empty tokens
        tokens = [t for t in tokens if t]
        return tokens


# Module-level singleton
translation_service = TranslationService()
