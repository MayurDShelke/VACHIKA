"""
Speech recognition service (Whisper).
"""

import io
import tempfile
import time

from loguru import logger

from app.core.config import settings
from app.core.exceptions import NoSpeechError, TranscriptionError
from app.schemas.speech import TranscribeResponse


class SpeechService:
    """Loads the Whisper model and transcribes audio."""

    def __init__(self) -> None:
        self.model = None
        self._loaded = False

    def load(self) -> None:
        """Load Whisper model at startup."""
        try:
            import whisper

            logger.info(
                f"Loading Whisper model '{settings.WHISPER_MODEL_SIZE}'..."
            )
            self.model = whisper.load_model(settings.WHISPER_MODEL_SIZE)
            self._loaded = True
            logger.info("SpeechService ready.")
        except Exception as e:
            logger.error(f"Failed to load Whisper model: {e}")
            raise TranscriptionError(f"Could not load Whisper: {e}")

    async def transcribe(
        self, audio_bytes: bytes, language: str | None = None
    ) -> TranscribeResponse:
        """Transcribe audio bytes to text."""
        if not self._loaded or self.model is None:
            raise TranscriptionError("Speech service not loaded.")

        start = time.perf_counter()

        try:
            # Write audio to a temp file (Whisper needs a file path)
            with tempfile.NamedTemporaryFile(
                suffix=".wav", delete=True
            ) as tmp:
                tmp.write(audio_bytes)
                tmp.flush()

                options: dict = {}
                if language:
                    options["language"] = language

                result = self.model.transcribe(tmp.name, **options)

        except Exception as e:
            logger.error(f"Whisper transcription failed: {e}")
            raise TranscriptionError(str(e))

        transcript = result.get("text", "").strip()
        if not transcript:
            raise NoSpeechError()

        detected_lang = result.get("language", language or "en")

        # Estimate confidence from average log-prob of segments
        segments = result.get("segments", [])
        if segments:
            avg_logprob = sum(s.get("avg_logprob", -1) for s in segments) / len(
                segments
            )
            # Convert log-prob to a 0-1 confidence (rough heuristic)
            import math

            confidence = round(min(1.0, max(0.0, math.exp(avg_logprob))), 4)
        else:
            confidence = 0.0

        elapsed_ms = int((time.perf_counter() - start) * 1000)

        return TranscribeResponse(
            transcript=transcript,
            language_detected=detected_lang,
            confidence=confidence,
            processing_time_ms=elapsed_ms,
        )


# Module-level singleton
speech_service = SpeechService()
