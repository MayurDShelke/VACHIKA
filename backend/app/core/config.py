"""
Application settings loaded from environment variables / .env file.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    # ── App ────────────────────────────────────────────────
    APP_NAME: str = "VACHIKA API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    API_V1_PREFIX: str = "/api/v1"

    # ── CORS ───────────────────────────────────────────────
    CORS_ORIGINS: list[str] = ["*"]

    # ── Supabase ───────────────────────────────────────────
    SUPABASE_URL: str = ""
    SUPABASE_KEY: str = ""

    # ── Sign Recognition Model ─────────────────────────────
    MODEL_PATH: str = "checkpoints/best_model.pt"
    MODEL_VERSION: str = "v1.0.0"
    CONFIDENCE_THRESHOLD: float = 0.60
    NUM_CLASSES: int = 21  # 20 signs + no_sign
    SEQUENCE_LENGTH: int = 30
    FEATURE_SIZE: int = 147

    # ── Whisper (Speech Recognition) ───────────────────────
    WHISPER_MODEL_SIZE: str = "small"

    # ── Upload Limits ──────────────────────────────────────
    MAX_CLIP_SIZE_MB: int = 10
    MAX_CLIP_DURATION_S: int = 5
    MAX_AUDIO_SIZE_MB: int = 10
    MAX_AUDIO_DURATION_S: int = 30
    MAX_TEXT_LENGTH: int = 500

    # ── Rate Limiting ──────────────────────────────────────
    RATE_LIMIT_SIGN: str = "10/minute"
    RATE_LIMIT_SPEECH: str = "10/minute"
    RATE_LIMIT_TRANSLATE: str = "30/minute"
    RATE_LIMIT_DICTIONARY: str = "60/minute"
    RATE_LIMIT_CONVERSATIONS: str = "30/minute"
    RATE_LIMIT_FEEDBACK: str = "10/minute"

    # ── Supported ──────────────────────────────────────────
    SUPPORTED_LANGUAGES: list[str] = ["en", "hi", "mr"]
    SUPPORTED_CLIP_FORMATS: list[str] = [".mp4", ".webm", ".mov"]
    SUPPORTED_AUDIO_FORMATS: list[str] = [".wav", ".mp3", ".m4a", ".webm"]


settings = Settings()
