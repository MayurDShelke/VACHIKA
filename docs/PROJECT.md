# VACHIKA — Project Definition & Requirements

**Tagline:** Every Expression Deserves a Voice.
**Type:** AI-powered mobile app · **Platform:** Android (Flutter) · **Connectivity:** Online only · **Language:** Indian Sign Language (ISL)

---

## 1. Overview

VACHIKA is a two-way ISL communication app. It converts signs into text and speech, converts speech or text into ISL sign videos, and offers a Conversation Mode so a Deaf and a hearing person can talk using one phone.

## 2. Problem

Most hearing people do not know ISL, and interpreters are not always available. Existing options (writing, separate speech-to-text apps, limited sign tools) are slow and one-directional.

## 3. Objectives

1. Recognize a defined set of ISL signs from the camera.
2. Turn recognized signs into text and speech.
3. Turn speech/typed text into verified ISL sign videos.
4. Provide a shared two-person Conversation Mode.
5. Support English, Hindi and Marathi.
6. Be accessible, simple and privacy-respecting.

## 4. Users

- **Deaf individuals:** sign to be understood, read and watch replies.
- **Hearing individuals:** speak or type, read and hear replies.
- **Others:** family, educators, ISL learners.

## 5. Scope

**In scope (MVP)**
- Android app, online only
- ~20 isolated ISL signs + "no sign" class
- Sign → text → speech
- Speech/text → ISL video sequence (dictionary-based)
- Conversation Mode, searchable dictionary
- Optional history, accessibility settings
- Backend, database, model training and server-side inference

**Out of scope (initially)**
- iOS, offline use
- Continuous sentence-level translation
- Full ISL vocabulary and all regional variants
- Facial-expression/grammar interpretation
- 3D signing avatars
- Replacing human interpreters

## 6. Functional requirements

| ID | Requirement |
|---|---|
| FR-01 | **Sign → Speech:** request camera permission, record a short clip, upload, show top prediction with confidence, allow retry/correction, speak the confirmed text |
| FR-02 | **Speech → Sign:** record speech, show editable transcript, map to signs, play verified videos with replay/pause/speed |
| FR-03 | **Text → Sign:** typed input follows the same path as FR-02 |
| FR-04 | **Conversation Mode:** turn-based, clear speaker indicator, shared transcript, replay, correction |
| FR-05 | **Language selection:** English, Hindi, Marathi |
| FR-06 | **Dictionary:** search, categories, demo videos, verified variants |
| FR-07 | **Accessibility:** text size, high contrast, visual alerts, haptics, reduced motion, screen-reader labels |
| FR-08 | **History:** optional, viewable, deletable |

## 7. Non-functional requirements

- **Performance:** sign result within ~3 s of upload; UI stays responsive during upload.
- **Reliability:** handle permission denial, network loss, timeouts, missing videos; uncertain predictions are never shown as confirmed.
- **Accessibility:** nothing communicated by sound alone; scalable text; labelled controls.
- **Privacy/Security:** HTTPS, permission-based camera/mic, no stored recordings, size and rate limits on uploads, secrets outside source code.

## 8. MVP success criteria

| Metric | Target |
|---|---|
| Vocabulary | 20 signs + "no sign" |
| Test accuracy (unseen signers) | ≥ 80% |
| End-to-end latency (clip upload → result) | ≤ 3 s on normal mobile data |
| Speech → sign | Works for every word in the 20-sign vocabulary in all 3 languages |
| Demo | Both directions and Conversation Mode working on a real Android phone |

## 9. Timeline (target, ~10 weeks)

| Week | Milestone |
|---|---|
| 1 | Finalize docs, `API.md`, repo/CI setup, dataset and video-source decisions |
| 2–3 | Dataset prep, landmark extraction, 20-sign vocabulary |
| 4–5 | Train/evaluate BiLSTM and TCN, pick the model |
| 6 | FastAPI: recognize, ASR, dictionary endpoints; Supabase schema |
| 7–8 | Flutter app: theme, navigation, sign→speech, speech→sign, dictionary |
| 9 | Conversation Mode, history, accessibility settings |
| 10 | Testing with unseen signers, ISL-literate validation, fixes, demo |

## 10. Risks and assumptions

- Dataset licences and quality limit what can be trained and shipped.
- Verified sign videos must be sourced (ISLRTC with permission, or self-recorded with an ISL signer) or speech → sign has no output.
- Whisper quality on Hindi/Marathi must be benchmarked.
- Server compute (CPU vs GPU, hosting) affects latency and cost.
- Translation quality needs validation by Deaf ISL users or qualified experts.
- The app must state its real capabilities honestly.

## 11. Summary

| Item | Value |
|---|---|
| Mobile | Flutter (Android) |
| Backend | Python, FastAPI |
| AI | MediaPipe, PyTorch, Whisper |
| Data | Supabase |
| Languages | English, Hindi, Marathi |
| Status | In development |

**VACHIKA — Every Expression Deserves a Voice.**
