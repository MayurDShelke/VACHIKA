# VACHIKA — API Reference

**Base URL:** `/api/v1`
**Content Types:** `application/json` unless stated otherwise (file uploads use `multipart/form-data`).
**Authentication:** Optional for MVP. Endpoints that touch user-specific data (history, feedback) accept an optional `Authorization: Bearer <token>` header.

---

## 1. Health

### `GET /health`

Server and model readiness check.

**Response `200 OK`**

```json
{
  "status": "ok",
  "model_version": "v1.0.0",
  "whisper_model": "small",
  "timestamp": "2026-11-12T12:00:00Z"
}
```

---

## 2. Sign Recognition

### `POST /sign/recognize`

Upload a short video clip and receive the top predicted ISL sign labels.

**Request** `multipart/form-data`

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `clip` | file | yes | Max 10 MB, max 5 s, formats: `.mp4`, `.webm`, `.mov` | Recorded sign video clip |
| `language` | string | no | `en` (default), `hi`, `mr` | Preferred language for the returned label text |

**Response `200 OK`**

```json
{
  "predictions": [
    {
      "rank": 1,
      "gloss": "HELLO",
      "label": "Hello",
      "confidence": 0.92
    },
    {
      "rank": 2,
      "gloss": "THANK_YOU",
      "label": "Thank you",
      "confidence": 0.05
    },
    {
      "rank": 3,
      "gloss": "GOOD",
      "label": "Good",
      "confidence": 0.02
    }
  ],
  "is_confident": true,
  "threshold": 0.60,
  "model_version": "v1.0.0",
  "processing_time_ms": 820
}
```

**Fields**

| Field | Type | Description |
|---|---|---|
| `predictions` | array | Top-3 predictions sorted by confidence descending |
| `predictions[].rank` | int | 1, 2 or 3 |
| `predictions[].gloss` | string | Canonical gloss label (e.g. `HELLO`, `NO_SIGN`) |
| `predictions[].label` | string | Human-readable label in the requested language |
| `predictions[].confidence` | float | 0.0–1.0 |
| `is_confident` | bool | `true` if top prediction ≥ threshold **and** gloss ≠ `NO_SIGN` |
| `threshold` | float | Confidence threshold used |
| `model_version` | string | Model version that produced the result |
| `processing_time_ms` | int | Server-side processing time in milliseconds |

**Error Responses**

| Status | Code | When |
|---|---|---|
| `400` | `INVALID_FORMAT` | Unsupported file type or corrupt video |
| `400` | `CLIP_TOO_LONG` | Clip exceeds 5 s |
| `413` | `FILE_TOO_LARGE` | File exceeds 10 MB |
| `422` | `NO_LANDMARKS` | MediaPipe could not detect hands or pose in any frame |
| `429` | `RATE_LIMITED` | Too many requests from this client |
| `500` | `INFERENCE_ERROR` | Model inference failed |

---

## 3. Speech Recognition

### `POST /speech/transcribe`

Upload an audio recording and receive a text transcript.

**Request** `multipart/form-data`

| Field | Type | Required | Constraints | Description |
|---|---|---|---|---|
| `audio` | file | yes | Max 10 MB, max 30 s, formats: `.wav`, `.mp3`, `.m4a`, `.webm` | Audio recording |
| `language` | string | no | `en` (default), `hi`, `mr` | Language hint for Whisper |

**Response `200 OK`**

```json
{
  "transcript": "I need water please",
  "language_detected": "en",
  "confidence": 0.94,
  "processing_time_ms": 1200
}
```

**Fields**

| Field | Type | Description |
|---|---|---|
| `transcript` | string | Recognized text (editable on the client side) |
| `language_detected` | string | Language code detected by Whisper |
| `confidence` | float | Overall transcription confidence 0.0–1.0 |
| `processing_time_ms` | int | Server-side processing time |

**Error Responses**

| Status | Code | When |
|---|---|---|
| `400` | `INVALID_FORMAT` | Unsupported audio format |
| `400` | `AUDIO_TOO_LONG` | Audio exceeds 30 s |
| `413` | `FILE_TOO_LARGE` | File exceeds 10 MB |
| `422` | `NO_SPEECH` | No speech detected in audio |
| `429` | `RATE_LIMITED` | Too many requests |
| `500` | `TRANSCRIPTION_ERROR` | Whisper failed |

---

## 4. Translation

### `POST /translate/text-to-sign`

Convert text into an ordered sequence of sign dictionary entries with video URLs.

**Request** `application/json`

```json
{
  "text": "Hello how are you",
  "source_language": "en"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `text` | string | yes | Input text (max 500 characters) |
| `source_language` | string | no | `en` (default), `hi`, `mr` |

**Response `200 OK`**

```json
{
  "input_text": "Hello how are you",
  "tokens": ["hello", "how", "are", "you"],
  "signs": [
    {
      "token": "hello",
      "sign_id": "sign_001",
      "gloss": "HELLO",
      "video_url": "https://storage.supabase.co/signs/hello.mp4",
      "available": true
    },
    {
      "token": "how",
      "sign_id": null,
      "gloss": null,
      "video_url": null,
      "available": false
    },
    {
      "token": "are",
      "sign_id": null,
      "gloss": null,
      "video_url": null,
      "available": false
    },
    {
      "token": "you",
      "sign_id": "sign_005",
      "gloss": "YOU",
      "video_url": "https://storage.supabase.co/signs/you.mp4",
      "available": true
    }
  ],
  "coverage": 0.50,
  "unavailable_words": ["how", "are"]
}
```

**Fields**

| Field | Type | Description |
|---|---|---|
| `input_text` | string | Echo of the input |
| `tokens` | array[string] | Tokenized and normalized words/phrases |
| `signs` | array | Ordered sign lookup results (one per token) |
| `signs[].token` | string | The source word/phrase |
| `signs[].sign_id` | string \| null | Sign ID if found |
| `signs[].gloss` | string \| null | Canonical gloss if found |
| `signs[].video_url` | string \| null | Public video URL if found |
| `signs[].available` | bool | Whether a verified sign video exists |
| `coverage` | float | Fraction of tokens with a matching sign (0.0–1.0) |
| `unavailable_words` | array[string] | Tokens with no matching sign |

---

### `POST /translate/gloss-to-text`

Convert a sign gloss label into human-readable text in the requested language.

**Request** `application/json`

```json
{
  "gloss": "THANK_YOU",
  "target_language": "hi"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `gloss` | string | yes | Canonical gloss label |
| `target_language` | string | no | `en` (default), `hi`, `mr` |

**Response `200 OK`**

```json
{
  "gloss": "THANK_YOU",
  "text": "धन्यवाद",
  "language": "hi"
}
```

**Error Responses**

| Status | Code | When |
|---|---|---|
| `404` | `GLOSS_NOT_FOUND` | Gloss does not exist in the dictionary |

---

## 5. Sign Dictionary

### `GET /signs`

List all signs, with optional filtering.

**Query Parameters**

| Param | Type | Default | Description |
|---|---|---|---|
| `category` | string | — | Filter by category (e.g. `greetings`, `common`, `needs`) |
| `search` | string | — | Search term matched against labels in all languages |
| `language` | string | `en` | Language for returned labels |
| `page` | int | `1` | Page number (1-indexed) |
| `page_size` | int | `20` | Items per page (max 50) |

**Response `200 OK`**

```json
{
  "signs": [
    {
      "sign_id": "sign_001",
      "gloss": "HELLO",
      "label": "Hello",
      "category": "greetings",
      "video_url": "https://storage.supabase.co/signs/hello.mp4",
      "verified": true
    }
  ],
  "total": 21,
  "page": 1,
  "page_size": 20
}
```

---

### `GET /signs/{sign_id}`

Get details for a single sign, including all language labels and variants.

**Response `200 OK`**

```json
{
  "sign_id": "sign_001",
  "gloss": "HELLO",
  "labels": {
    "en": "Hello",
    "hi": "नमस्ते",
    "mr": "नमस्कार"
  },
  "category": "greetings",
  "description": "Open palm wave near the face",
  "video_url": "https://storage.supabase.co/signs/hello.mp4",
  "verified": true,
  "variants": [
    {
      "variant_id": "var_001",
      "region": "Maharashtra",
      "video_url": "https://storage.supabase.co/signs/hello_mh.mp4",
      "verified": true
    }
  ]
}
```

**Error Responses**

| Status | Code | When |
|---|---|---|
| `404` | `SIGN_NOT_FOUND` | No sign with this ID |

---

## 6. Conversations

### `POST /conversations`

Create a new conversation session.

**Request** `application/json`

```json
{
  "language": "en"
}
```

**Response `201 Created`**

```json
{
  "conversation_id": "conv_abc123",
  "language": "en",
  "created_at": "2026-11-12T12:00:00Z",
  "messages": []
}
```

---

### `GET /conversations/{conversation_id}`

Retrieve a conversation with its message history.

**Response `200 OK`**

```json
{
  "conversation_id": "conv_abc123",
  "language": "en",
  "created_at": "2026-11-12T12:00:00Z",
  "messages": [
    {
      "message_id": "msg_001",
      "participant": "deaf",
      "direction": "sign_to_text",
      "gloss": "HELLO",
      "text": "Hello",
      "timestamp": "2026-11-12T12:01:00Z"
    },
    {
      "message_id": "msg_002",
      "participant": "hearing",
      "direction": "text_to_sign",
      "text": "How are you?",
      "signs": [
        { "gloss": "HOW", "available": false },
        { "gloss": "YOU", "available": true, "video_url": "https://storage.supabase.co/signs/you.mp4" }
      ],
      "timestamp": "2026-11-12T12:01:30Z"
    }
  ]
}
```

---

### `POST /conversations/{conversation_id}/messages`

Add a message to a conversation. Used by Conversation Mode to append each turn.

**Request** `application/json`

```json
{
  "participant": "deaf",
  "direction": "sign_to_text",
  "gloss": "THANK_YOU",
  "text": "Thank you"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `participant` | string | yes | `deaf` or `hearing` |
| `direction` | string | yes | `sign_to_text` or `text_to_sign` |
| `gloss` | string | no | Gloss if from sign recognition |
| `text` | string | yes | Text content of the message |
| `signs` | array | no | Sign lookup results if direction is `text_to_sign` |

**Response `201 Created`**

```json
{
  "message_id": "msg_003",
  "participant": "deaf",
  "direction": "sign_to_text",
  "gloss": "THANK_YOU",
  "text": "Thank you",
  "timestamp": "2026-11-12T12:02:00Z"
}
```

---

### `DELETE /conversations/{conversation_id}`

Delete a conversation and all its messages. User-controlled history deletion.

**Response `204 No Content`**

---

## 7. Feedback

### `POST /feedback`

Submit a user correction for a sign prediction or transcription.

**Request** `application/json`

```json
{
  "type": "sign_correction",
  "predicted_gloss": "GOOD",
  "corrected_gloss": "THANK_YOU",
  "context": "conversation",
  "conversation_id": "conv_abc123"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `type` | string | yes | `sign_correction`, `transcription_correction`, or `general` |
| `predicted_gloss` | string | no | What the model predicted |
| `corrected_gloss` | string | no | What the user corrected it to |
| `predicted_text` | string | no | Predicted transcript (for speech corrections) |
| `corrected_text` | string | no | Corrected transcript |
| `context` | string | no | `sign_to_speech`, `speech_to_sign`, `conversation`, `dictionary` |
| `conversation_id` | string | no | If the correction is within a conversation |
| `comment` | string | no | Free-text comment (max 500 chars) |

**Response `201 Created`**

```json
{
  "feedback_id": "fb_001",
  "type": "sign_correction",
  "created_at": "2026-11-12T12:05:00Z"
}
```

---

## 8. Common Error Format

All error responses share a consistent structure:

```json
{
  "error": {
    "code": "INVALID_FORMAT",
    "message": "Unsupported file type. Accepted formats: .mp4, .webm, .mov",
    "details": null
  }
}
```

| Field | Type | Description |
|---|---|---|
| `error.code` | string | Machine-readable error code (UPPER_SNAKE_CASE) |
| `error.message` | string | Human-readable description |
| `error.details` | object \| null | Additional context when available |

---

## 9. Rate Limits

| Endpoint group | Limit |
|---|---|
| `/sign/recognize` | 10 requests / minute / client |
| `/speech/transcribe` | 10 requests / minute / client |
| `/translate/*` | 30 requests / minute / client |
| `/signs` | 60 requests / minute / client |
| `/conversations` | 30 requests / minute / client |
| `/feedback` | 10 requests / minute / client |

Rate-limited responses return `429 Too Many Requests` with a `Retry-After` header (seconds).

---

## 10. Versioning

All endpoints are prefixed with `/api/v1`. Breaking changes will use a new version prefix (`/api/v2`). Non-breaking additions (new optional fields) may be added without a version bump.

**VACHIKA — Every Expression Deserves a Voice.**
