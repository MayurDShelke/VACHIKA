"""
Custom exceptions and global error handlers.
"""

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from loguru import logger


# ── Custom Exceptions ─────────────────────────────────────────


class VachikaError(Exception):
    """Base exception for all VACHIKA errors."""

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int = 400,
        details: dict | None = None,
    ):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details
        super().__init__(message)


class InvalidFormatError(VachikaError):
    def __init__(self, message: str = "Unsupported file format."):
        super().__init__(code="INVALID_FORMAT", message=message, status_code=400)


class ClipTooLongError(VachikaError):
    def __init__(self, max_seconds: int = 5):
        super().__init__(
            code="CLIP_TOO_LONG",
            message=f"Clip exceeds maximum duration of {max_seconds} seconds.",
            status_code=400,
        )


class AudioTooLongError(VachikaError):
    def __init__(self, max_seconds: int = 30):
        super().__init__(
            code="AUDIO_TOO_LONG",
            message=f"Audio exceeds maximum duration of {max_seconds} seconds.",
            status_code=400,
        )


class FileTooLargeError(VachikaError):
    def __init__(self, max_mb: int = 10):
        super().__init__(
            code="FILE_TOO_LARGE",
            message=f"File exceeds maximum size of {max_mb} MB.",
            status_code=413,
        )


class NoLandmarksError(VachikaError):
    def __init__(self):
        super().__init__(
            code="NO_LANDMARKS",
            message="Could not detect hands or pose in any frame. Please ensure hands and upper body are visible.",
            status_code=422,
        )


class NoSpeechError(VachikaError):
    def __init__(self):
        super().__init__(
            code="NO_SPEECH",
            message="No speech detected in the audio.",
            status_code=422,
        )


class InferenceError(VachikaError):
    def __init__(self, message: str = "Model inference failed."):
        super().__init__(
            code="INFERENCE_ERROR", message=message, status_code=500
        )


class TranscriptionError(VachikaError):
    def __init__(self, message: str = "Speech transcription failed."):
        super().__init__(
            code="TRANSCRIPTION_ERROR", message=message, status_code=500
        )


class NotFoundError(VachikaError):
    def __init__(self, resource: str, identifier: str):
        super().__init__(
            code=f"{resource.upper()}_NOT_FOUND",
            message=f"{resource} '{identifier}' not found.",
            status_code=404,
        )


# ── Error Handlers ────────────────────────────────────────────


def register_exception_handlers(app: FastAPI) -> None:
    """Register all custom exception handlers on the FastAPI app."""

    @app.exception_handler(VachikaError)
    async def vachika_error_handler(
        request: Request, exc: VachikaError
    ) -> JSONResponse:
        logger.warning(
            f"{exc.code}: {exc.message} | path={request.url.path}"
        )
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": {
                    "code": exc.code,
                    "message": exc.message,
                    "details": exc.details,
                }
            },
        )

    @app.exception_handler(Exception)
    async def unhandled_error_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        logger.exception(
            f"Unhandled error on {request.method} {request.url.path}"
        )
        return JSONResponse(
            status_code=500,
            content={
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "An unexpected error occurred.",
                    "details": None,
                }
            },
        )
