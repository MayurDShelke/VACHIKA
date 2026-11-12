# VACHIKA

### Every Expression Deserves a Voice.

VACHIKA is an AI-powered, two-way Indian Sign Language (ISL) communication app for Deaf and hearing people. This version targets **Android** and requires an **internet connection**.

## What it does

| Mode | Flow |
|---|---|
| **Sign → Speech** | Camera records a short sign clip → backend extracts landmarks and recognizes the sign → text shown → spoken via TTS |
| **Speech → Sign** | Mic/typed text → speech recognition → text-to-ISL lookup → verified ISL videos played in order |
| **Conversation Mode** | One phone, two people, turn-based use of both flows with a shared transcript |

Languages: English, Hindi, Marathi.

## Current scope (MVP)

- Android only (Flutter). iOS is future work.
- Online only. No offline mode.
- Recognition of ~20 isolated ISL signs plus a "no sign" class. This is **not** sentence-level translation.
- Speech → sign uses verified dictionary videos, not generated animation.

## Tech stack

| Layer | Technology |
|---|---|
| App | Flutter, Dart, Riverpod, GoRouter |
| Backend | Python, FastAPI |
| AI (sign) | MediaPipe (Hands + Pose), PyTorch |
| AI (speech) | Whisper (server-side, en/hi/mr) |
| TTS | Android native TTS |
| Data | Supabase (PostgreSQL, Storage, Auth) |

## Repository structure

```text
VACHIKA/
├── vachika/      # Flutter Android app
├── backend/      # FastAPI service (includes inference)
├── ai_model/     # Dataset prep, training, evaluation
├── docs/         # PROJECT, ARCHITECTURE, DESIGN, AI_MODEL, API
└── README.md
```

## Documentation

| File | Contents |
|---|---|
| `PROJECT.md` | Requirements, scope, MVP targets, timeline |
| `ARCHITECTURE.md` | System design, pipelines, backend, data |
| `AI_MODEL.md` | Dataset, features, training, evaluation, serving |
| `DESIGN.md` | UI/UX and accessibility rules |
| `API.md` | Endpoint schemas (to be written before coding) |

## Privacy

Clips and audio are processed in memory and deleted immediately. Raw recordings are never stored. Conversation history is optional and user-controlled.

## Status

In development (individual project). Capabilities are stated only after validation.
