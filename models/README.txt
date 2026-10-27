Smart Pharmacy - Offline Desktop Speech Recognition Models (Sherpa-ONNX 1.13.8)
================================================================================

This directory houses offline neural acoustic models for Desktop Windows/macOS/Linux.
When present, Smart Pharmacy uses Sherpa-ONNX for 100% offline speech recognition without
relying on Windows Speech API (SAPI).

Supported Model Families:
-------------------------
1. SenseVoice (Recommended for English & Multilingual - Fast & Accurate, ~35MB):
   - model.int8.onnx (or model.onnx)
   - tokens.txt

2. Whisper Tiny English (~40MB):
   - tiny.en-encoder.onnx
   - tiny.en-decoder.onnx
   - tiny.en-tokens.txt

Download Link:
https://github.com/k2-fsa/sherpa-onnx/releases/tag/asr-models

Mobile Note (Android & iOS):
-----------------------------
Mobile devices automatically use the native Google Speech (Android) & Apple Speech (iOS)
engines via `speech_to_text`. Zero model downloads are required on mobile!

