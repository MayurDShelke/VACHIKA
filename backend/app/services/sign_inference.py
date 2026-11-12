"""
Sign recognition inference service.

Handles MediaPipe landmark extraction, preprocessing, and PyTorch model inference.
"""

import io
import time
from pathlib import Path

import cv2
import numpy as np
import torch
from loguru import logger

from app.core.config import settings
from app.core.exceptions import InferenceError, NoLandmarksError
from app.schemas.sign import Prediction, SignRecognizeResponse


class SignInferenceService:
    """Loads the sign recognition model and runs inference on video clips."""

    def __init__(self) -> None:
        self.model: torch.nn.Module | None = None
        self.mp_hands = None
        self.mp_pose = None
        self.label_map: dict[int, str] = {}
        self._loaded = False

    def load(self) -> None:
        """Load MediaPipe solutions and PyTorch model at startup."""
        import mediapipe as mp

        # ── MediaPipe ─────────────────────────────────────
        self.mp_hands = mp.solutions.hands.Hands(
            static_image_mode=False,
            max_num_hands=2,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        )
        self.mp_pose = mp.solutions.pose.Pose(
            static_image_mode=False,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        )

        # ── Model ─────────────────────────────────────────
        model_path = Path(settings.MODEL_PATH)
        if model_path.exists():
            checkpoint = torch.load(model_path, map_location="cpu", weights_only=True)
            self.model = checkpoint.get("model", None)
            self.label_map = checkpoint.get("label_map", {})
            if self.model is not None:
                self.model.eval()
            logger.info(f"Sign model loaded from {model_path}")
        else:
            logger.warning(
                f"Model file not found at {model_path}. "
                "Inference will return a placeholder response."
            )
            # Build a placeholder label map for development
            self.label_map = {i: f"SIGN_{i}" for i in range(settings.NUM_CLASSES - 1)}
            self.label_map[settings.NUM_CLASSES - 1] = "NO_SIGN"

        self._loaded = True
        logger.info("SignInferenceService ready.")

    # ── Public API ────────────────────────────────────────────

    async def recognize(
        self, clip_bytes: bytes, language: str = "en"
    ) -> SignRecognizeResponse:
        """Run full pipeline: frames → landmarks → model → top-3."""
        if not self._loaded:
            raise InferenceError("Sign inference service not loaded.")

        start = time.perf_counter()

        # 1. Decode frames
        frames = self._decode_frames(clip_bytes)
        if not frames:
            raise InferenceError("Could not decode any frames from the clip.")

        # 2. Extract landmarks
        sequence = self._extract_landmark_sequence(frames)
        if sequence is None:
            raise NoLandmarksError()

        # 3. Resample to fixed length
        sequence = self._resample(sequence, settings.SEQUENCE_LENGTH)

        # 4. Run inference
        predictions = self._infer(sequence, language)

        elapsed_ms = int((time.perf_counter() - start) * 1000)

        top = predictions[0]
        is_confident = (
            top.confidence >= settings.CONFIDENCE_THRESHOLD
            and top.gloss != "NO_SIGN"
        )

        return SignRecognizeResponse(
            predictions=predictions,
            is_confident=is_confident,
            threshold=settings.CONFIDENCE_THRESHOLD,
            model_version=settings.MODEL_VERSION,
            processing_time_ms=elapsed_ms,
        )

    # ── Internals ─────────────────────────────────────────────

    def _decode_frames(self, clip_bytes: bytes) -> list[np.ndarray]:
        """Decode video bytes into a list of BGR frames."""
        import tempfile

        frames: list[np.ndarray] = []
        with tempfile.NamedTemporaryFile(suffix=".mp4", delete=True) as tmp:
            tmp.write(clip_bytes)
            tmp.flush()
            cap = cv2.VideoCapture(tmp.name)
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    break
                frames.append(frame)
            cap.release()
        return frames

    def _extract_landmarks(self, frame: np.ndarray) -> np.ndarray | None:
        """
        Extract 147-dim landmark vector from a single frame.
        Layout: [left_hand(63) | right_hand(63) | pose_subset(21)] = 147
        """
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        # Hands
        hand_result = self.mp_hands.process(rgb)
        left_hand = np.zeros(63, dtype=np.float32)
        right_hand = np.zeros(63, dtype=np.float32)

        if hand_result.multi_hand_landmarks:
            for hand_lm, handedness in zip(
                hand_result.multi_hand_landmarks,
                hand_result.multi_handedness,
            ):
                coords = np.array(
                    [[lm.x, lm.y, lm.z] for lm in hand_lm.landmark],
                    dtype=np.float32,
                ).flatten()
                label = handedness.classification[0].label
                if label == "Left":
                    left_hand = coords
                else:
                    right_hand = coords

        # Pose subset: nose(0), left_shoulder(11), right_shoulder(12),
        #              left_elbow(13), right_elbow(14), left_wrist(15), right_wrist(16)
        pose_result = self.mp_pose.process(rgb)
        pose_subset = np.zeros(21, dtype=np.float32)
        POSE_INDICES = [0, 11, 12, 13, 14, 15, 16]

        if pose_result.pose_landmarks:
            for i, idx in enumerate(POSE_INDICES):
                lm = pose_result.pose_landmarks.landmark[idx]
                pose_subset[i * 3 : i * 3 + 3] = [lm.x, lm.y, lm.z]

        features = np.concatenate([left_hand, right_hand, pose_subset])

        # Return None if both hands and pose are all zeros
        if np.all(features == 0):
            return None

        return features

    def _extract_landmark_sequence(
        self, frames: list[np.ndarray]
    ) -> np.ndarray | None:
        """Extract landmark vectors for all frames; return None if no landmarks found."""
        sequence: list[np.ndarray] = []
        for frame in frames:
            lm = self._extract_landmarks(frame)
            if lm is not None:
                sequence.append(lm)

        if not sequence:
            return None

        return np.stack(sequence)  # (T, 147)

    def _resample(self, sequence: np.ndarray, target_len: int) -> np.ndarray:
        """Resample a (T, F) sequence to (target_len, F) via linear interpolation."""
        t = sequence.shape[0]
        if t == target_len:
            return sequence
        indices = np.linspace(0, t - 1, target_len).astype(int)
        return sequence[indices]

    def _normalize(self, sequence: np.ndarray) -> np.ndarray:
        """
        Normalize landmarks: translate to shoulder midpoint,
        scale by shoulder width. Operates on (T, 147) array.
        """
        normalized = sequence.copy()
        for t in range(normalized.shape[0]):
            frame = normalized[t]
            # Pose subset starts at index 126
            # left_shoulder = 126 + 3*1 = 129..132, right_shoulder = 126 + 3*2 = 132..135
            l_shoulder = frame[129:132]
            r_shoulder = frame[132:135]
            midpoint = (l_shoulder + r_shoulder) / 2.0
            shoulder_width = np.linalg.norm(l_shoulder - r_shoulder)
            if shoulder_width < 1e-6:
                shoulder_width = 1.0

            # Translate and scale all (x,y,z) triplets
            for i in range(0, len(frame), 3):
                frame[i : i + 3] = (frame[i : i + 3] - midpoint) / shoulder_width

            normalized[t] = frame
        return normalized

    def _infer(
        self, sequence: np.ndarray, language: str
    ) -> list[Prediction]:
        """Run PyTorch inference and return top-3 predictions."""
        sequence = self._normalize(sequence)
        tensor = torch.tensor(sequence, dtype=torch.float32).unsqueeze(0)  # (1, 30, 147)

        if self.model is not None:
            with torch.no_grad():
                logits = self.model(tensor)
                probs = torch.softmax(logits, dim=-1).squeeze(0)
        else:
            # Placeholder: return uniform probabilities
            probs = torch.ones(settings.NUM_CLASSES) / settings.NUM_CLASSES

        top3 = torch.topk(probs, k=min(3, len(probs)))
        predictions: list[Prediction] = []
        for rank, (score, idx) in enumerate(
            zip(top3.values.tolist(), top3.indices.tolist()), start=1
        ):
            gloss = self.label_map.get(idx, f"UNKNOWN_{idx}")
            predictions.append(
                Prediction(
                    rank=rank,
                    gloss=gloss,
                    label=self._gloss_to_label(gloss, language),
                    confidence=round(score, 4),
                )
            )
        return predictions

    def _gloss_to_label(self, gloss: str, language: str) -> str:
        """
        Convert a gloss to a human-readable label.
        In production, this looks up the signs table. Stubbed for now.
        """
        # TODO: Replace with Supabase lookup
        return gloss.replace("_", " ").title()


# Module-level singleton
sign_inference_service = SignInferenceService()
