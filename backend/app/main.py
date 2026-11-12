"""
VACHIKA Backend — FastAPI Application Entry Point.

Initializes the app, loads AI models at startup, registers
routes, middleware, and exception handlers.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from loguru import logger
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.core.config import settings
from app.core.exceptions import register_exception_handlers
from app.core.limiter import limiter

# Route imports
from app.api.routes import (
    health,
    sign,
    speech,
    translation,
    signs,
    conversations,
    feedback,
)


# ── Lifespan: load models once at startup ─────────────────────


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load heavy resources (models) on startup, release on shutdown."""
    logger.info("Starting VACHIKA API...")

    # Load sign recognition model + MediaPipe
    from app.services.sign_inference import sign_inference_service

    sign_inference_service.load()

    # Load Whisper model
    from app.services.speech import speech_service

    try:
        speech_service.load()
    except Exception as e:
        logger.warning(f"Whisper not loaded (non-fatal for dev): {e}")

    logger.info("All models loaded. VACHIKA API is ready.")
    yield
    logger.info("Shutting down VACHIKA API.")


# ── Create App ────────────────────────────────────────────────


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.APP_NAME,
        version=settings.APP_VERSION,
        description=(
            "VACHIKA — Every Expression Deserves a Voice. "
            "Two-way Indian Sign Language communication API."
        ),
        docs_url="/docs",
        redoc_url="/redoc",
        lifespan=lifespan,
    )

    # ── Rate Limiting ─────────────────────────────────────
    app.state.limiter = limiter
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

    # ── CORS ──────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ── Exception Handlers ────────────────────────────────
    register_exception_handlers(app)

    # ── Routes ────────────────────────────────────────────
    api_prefix = settings.API_V1_PREFIX
    app.include_router(health.router, prefix=api_prefix)
    app.include_router(sign.router, prefix=api_prefix)
    app.include_router(speech.router, prefix=api_prefix)
    app.include_router(translation.router, prefix=api_prefix)
    app.include_router(signs.router, prefix=api_prefix)
    app.include_router(conversations.router, prefix=api_prefix)
    app.include_router(feedback.router, prefix=api_prefix)

    return app


app = create_app()
