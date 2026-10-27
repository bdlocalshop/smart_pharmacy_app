import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'desktop_sherpa_onnx_engine.dart';
import 'mobile_speech_to_text_engine.dart';
import 'voice_engine.dart';

/// Provider for application-wide voice input service.
final voiceInputServiceProvider = Provider<VoiceInputService>((ref) {
  final service = VoiceInputService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// Adaptive Hybrid Voice Recognition Service.
/// Automatically dispatches to the optimal architecture per platform:
/// - **Desktop (Windows, macOS, Linux)**: Uses `sherpa_onnx 1.13.8` with direct
///   audio recording via `record: ^7.1.2` for 100% offline, zero-network, SAPI-free recognition.
/// - **Mobile (Android, iOS)**: Uses `speech_to_text: ^7.5.0` backed by native Google Speech
///   and Apple Speech APIs for instant real-time typing and zero local model downloads.
class VoiceInputService {
  late final VoiceEngine _activeEngine;

  VoiceInputService({VoiceEngine? customEngine}) {
    if (customEngine != null) {
      _activeEngine = customEngine;
    } else if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      _activeEngine = DesktopSherpaOnnxEngine();
    } else {
      _activeEngine = MobileSpeechToTextEngine();
    }
  }

  /// The active underlying voice engine.
  VoiceEngine get activeEngine => _activeEngine;

  /// Name of the active engine for display in settings/tooltips.
  String get activeEngineName => _activeEngine.engineName;

  /// Whether the active engine is initialized.
  bool get isInitialized => _activeEngine.isInitialized;

  /// Whether speech recognition is currently listening.
  bool get isListening => _activeEngine.isListening;

  /// Whether voice recognition is available on this platform/device.
  bool get isAvailable => _activeEngine.isAvailable;

  /// The last recognized phrase.
  String get lastWords => _activeEngine.lastWords;

  /// The last error message, if any.
  String? get lastErrorMessage => _activeEngine.lastErrorMessage;

  /// Initializes the voice recognition service with permission checks.
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(SpeechRecognitionError error)? onError,
  }) async {
    return _activeEngine.initialize(
      onStatus: onStatus,
      onError: (errStr) {
        onError?.call(SpeechRecognitionError(errStr, false));
      },
    );
  }

  /// Starts listening for speech and streams results into the callback.
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    VoidCallback? onStarted,
    VoidCallback? onStopped,
    String? localeId,
  }) async {
    return _activeEngine.startListening(
      onResult: onResult,
      onStarted: onStarted,
      onStopped: onStopped,
      localeId: localeId,
    );
  }

  /// Stops active listening session.
  Future<void> stopListening() async {
    await _activeEngine.stopListening();
  }

  /// Cancels active listening session without processing pending audio.
  Future<void> cancelListening() async {
    await _activeEngine.cancelListening();
  }

  void dispose() {
    _activeEngine.dispose();
  }
}
