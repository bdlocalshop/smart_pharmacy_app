import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'voice_engine.dart';

/// Mobile speech recognition engine using `speech_to_text`.
/// Backed by native Google Speech on Android and Apple Speech on iOS.
/// Zero downloads, real-time typing preview, 100% free with no API keys.
class MobileSpeechToTextEngine implements VoiceEngine {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  String? _lastErrorMessage;
  String? _currentLocaleId;
  VoidCallback? _activeStoppedCallback;

  @override
  String get engineName => 'SpeechToText (Native Mobile Engine)';

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isListening => _isListening;

  @override
  bool get isAvailable => _speech.isAvailable;

  @override
  String get lastWords => _lastWords;

  @override
  String? get lastErrorMessage => _lastErrorMessage ?? _speech.lastError?.errorMsg;

  @override
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(String error)? onError,
  }) async {
    _lastErrorMessage = null;
    if (_isInitialized) return _speech.isAvailable;

    try {
      _isInitialized = await _speech.initialize(
        onStatus: (status) {
          _isListening = _speech.isListening;
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
            _activeStoppedCallback?.call();
          }
          onStatus?.call(status);
        },
        onError: (errorNotification) {
          _isListening = false;
          _lastErrorMessage = errorNotification.errorMsg;
          debugPrint('Mobile speech error: ${errorNotification.errorMsg}');
          _activeStoppedCallback?.call();
          onError?.call(errorNotification.errorMsg);
        },
        debugLogging: kDebugMode,
      );

      if (_isInitialized) {
        try {
          final sysLocale = await _speech.systemLocale();
          final availableLocales = await _speech.locales();
          _currentLocaleId = sysLocale?.localeId ??
              (availableLocales.isNotEmpty ? availableLocales.first.localeId : null);
        } catch (_) {}
      }

      return _isInitialized;
    } catch (e) {
      debugPrint('MobileSpeechToTextEngine initialize failed: $e');
      _lastErrorMessage = e.toString();
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    VoidCallback? onStarted,
    VoidCallback? onStopped,
    String? localeId,
  }) async {
    try {
      _lastErrorMessage = null;
      _activeStoppedCallback = onStopped;

      if (!_isInitialized) {
        final ready = await initialize();
        if (!ready) {
          _lastErrorMessage ??= 'Microphone initialization failed or permission was denied.';
          return false;
        }
      }

      if (_speech.isListening) {
        await stopListening();
      }

      _lastWords = '';
      _isListening = true;
      onStarted?.call();

      final targetLocale = localeId ?? _currentLocaleId;

      await _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastWords = result.recognizedWords;
          onResult(result.recognizedWords, result.finalResult);
          if (result.finalResult) {
            _isListening = false;
            onStopped?.call();
          }
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 45),
          pauseFor: const Duration(seconds: 5),
          localeId: targetLocale,
        ),
      );

      return true;
    } catch (e) {
      debugPrint('Error starting mobile speech recognition: $e');
      _lastErrorMessage = e.toString();
      _isListening = false;
      onStopped?.call();
      return false;
    }
  }

  @override
  Future<void> stopListening() async {
    if (_speech.isListening) {
      try {
        await _speech.stop();
      } catch (e) {
        debugPrint('Error stopping mobile speech: $e');
      }
    }
    _isListening = false;
    _activeStoppedCallback?.call();
  }

  @override
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      try {
        await _speech.cancel();
      } catch (e) {
        debugPrint('Error cancelling mobile speech: $e');
      }
    }
    _isListening = false;
    _activeStoppedCallback?.call();
  }

  @override
  void dispose() {
    cancelListening();
  }
}

