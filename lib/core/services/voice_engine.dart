import 'dart:async';
import 'package:flutter/foundation.dart';

/// Common abstraction for voice recognition engines.
/// Enables seamless hybrid switching between native mobile engines (`speech_to_text`)
/// and offline desktop engines (`sherpa_onnx`).
abstract class VoiceEngine {
  /// Name of the active engine for display/diagnostics.
  String get engineName;

  /// Whether the engine has been successfully initialized.
  bool get isInitialized;

  /// Whether speech recognition is currently active and capturing audio.
  bool get isListening;

  /// Whether the engine is available and supported on this device.
  bool get isAvailable;

  /// Last recognized transcription string.
  String get lastWords;

  /// Diagnostic error message if initialization or recognition failed.
  String? get lastErrorMessage;

  /// Initializes the voice recognition engine.
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(String error)? onError,
  });

  /// Starts listening for voice input, emitting partial and final transcriptions.
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    VoidCallback? onStarted,
    VoidCallback? onStopped,
    String? localeId,
  });

  /// Stops listening and finalizes transcription.
  Future<void> stopListening();

  /// Cancels active listening session discarding audio.
  Future<void> cancelListening();

  /// Disposes resources held by the engine.
  void dispose();
}

