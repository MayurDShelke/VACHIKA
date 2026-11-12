# VACHIKA — UI/UX Design Guidelines

**Tagline:** Every Expression Deserves a Voice.

## 1. Principles

1. **Accessibility first:** every key action works for Deaf and hearing users.
2. **Simple and clear:** minimal screens, short labels, obvious primary action.
3. **Consistent:** same spacing, type, components and behaviour everywhere.
4. **Inclusive:** do not assume literacy level or one preferred way to communicate.
5. **Communication over decoration:** calm, modern, no gradients, no decorative animation.

It must feel like a communication companion, not a chatbot, analytics dashboard or medical app.

## 2. Colour

| Name | Hex | Use |
|---|---|---|
| Porcelain | `#F7F6F2` | App background |
| Graphite | `#202522` | Text, dark surfaces |
| Forest Sage | `#344C43` | Primary buttons, selected items, brand |
| Soft Sage | `#A8B5A2` | Secondary accents |
| Stone | `#E7E5DC` | Cards, inputs, dividers |

Rules: no extra decorative colours, no gradients, never colour alone to convey meaning, keep sufficient contrast. Separate semantic colours (success, warning, error) are allowed and must be paired with an icon and text.

## 3. Typography and spacing

**Font:** Inter. Support system font scaling; avoid thin weights and unnecessary uppercase.

| Element | Size | Weight |
|---|---|---|
| Main heading | 28–32sp | Bold |
| Screen heading | 24sp | SemiBold |
| Section heading | 20sp | SemiBold |
| Card heading | 16–18sp | Medium |
| Body | 14–16sp | Regular |
| Button | 15–16sp | SemiBold |
| Supporting | 12–14sp | Regular |

**Spacing (8-pt):** XS 4 · SM 8 · MD 16 · LG 24 · XL 32 · XXL 40
**Radius:** buttons and inputs 12 · cards 16 · dialogs 20 · small 8

## 4. Navigation

Bottom navigation with icon and label: **Home · Dictionary · History · Settings**. Conversation Mode is prominent on Home. Keep navigation shallow, indicate the selected tab, and make it screen-reader friendly.

## 5. Screens

**Splash:** logo, name, tagline, simple loading.

**Onboarding:** three short slides (sign → speech, speech → sign, Conversation Mode), skip option, progress indicator.

**Preferences:** language (English, Hindi, Marathi), text size, high contrast, captions, haptics, reduced motion, visual notifications.

**Home:** two clear primary actions (Sign to Speech, Speech to Sign), prominent Conversation Mode, recent activity (if history is on), dictionary shortcut. No statistics or promo cards.

**Sign to Speech:**
- Camera preview with framing guide (hands and upper body)
- Record/stop control, upload and processing status
- Top result with confidence; "uncertain, please retry" when low
- Output language, edit/correct text, speak button
- Never show an uncertain prediction as confirmed

**Speech to Sign:**
- Large mic button and text input alternative
- Editable transcript, language selector
- Sign video player as the main output: replay, pause, speed, next/previous
- "Sign unavailable" shown clearly for missing words

**Conversation Mode:**
- Two clearly labelled participants (Hearing, Deaf) with distinct styling
- Visual and haptic turn indicator (never sound only)
- Chronological transcript, replay, correct and retry
- Only one input (mic or camera) active at a time

**Dictionary:** search, categories, sign name, description, demo video, verified variants.

**History:** list with date and time, search, delete. Opt-in and user-controlled.

**Settings:** language, text size, accessibility, notifications, haptics, motion, camera/mic permissions, privacy, history, account (if login is enabled).

## 6. Accessibility

- **Deaf users:** all feedback visual and text; transcripts; replayable, speed-adjustable videos; no sound-only alerts.
- **Hearing users:** speech output, readable transcripts, clear mic/recording state, typed input option.
- **Touch:** targets ≥ 48dp, spaced apart, icons always labelled.
- **Screen readers:** semantic labels, logical focus order, announce status changes.
- **Motion:** respect reduced-motion, no flashing, subtle functional transitions only.
- Accessibility settings must change the real UI, not just be stored.

## 7. Components

PrimaryButton, SecondaryButton, AppTextField, LanguageSelector, CameraPreviewCard, CameraGuideOverlay, MicrophoneButton, RecognitionStatus, TranslationResultCard, SignVideoPlayer, ConversationMessage, ParticipantIndicator, EmptyState, ErrorState, LoadingIndicator, AccessibilitySettingsTile.

## 8. States and messages

| Area | States |
|---|---|
| Button | default, pressed, disabled, loading, focused |
| Recognition | ready, recording, uploading, processing, success, uncertain, failed |
| Speech | ready, recording, transcribing, transcript ready, failed |
| Video | loading, playing, paused, completed, failed |
| Network | offline/no connection, timeout, retrying |

Errors are short, actionable and always offer recovery:
- "Camera permission is required to recognize signs."
- "Please move your hands into the frame."
- "We couldn't recognize that sign. Please try again."
- "Microphone permission is required for speech input."
- "No internet connection. Please connect and retry."
- "This sign video is currently unavailable."

## 9. Implementation

Central theme in `lib/core/theme/` (`app_colors`, `app_typography`, `app_spacing`, `app_theme`, `app_components`). No hard-coded styles in screens.

## 10. Review checklist

- [ ] One clear purpose and primary action per screen
- [ ] Palette, type and spacing follow the system
- [ ] Text scales without clipping; targets ≥ 48dp; icons labelled
- [ ] Deaf users get every important cue visually
- [ ] Camera, mic and upload states are obvious
- [ ] Loading, error, empty and no-network states designed
- [ ] Screen reader navigation works
- [ ] No unnecessary decoration

**VACHIKA — Every Expression Deserves a Voice.**
