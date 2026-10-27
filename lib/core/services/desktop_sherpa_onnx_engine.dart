import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;
import 'mobile_speech_to_text_engine.dart';
import 'voice_engine.dart';

/// Offline speech recognition engine for Windows, macOS & Linux Desktop.
/// Powered by `sherpa_onnx 1.13.8` with on-device neural acoustic models and
/// `record: ^7.1.2` for direct low-latency microphone audio streaming.
/// 100% offline, zero network dependencies, and independent of legacy Windows SAPI.
class DesktopSherpaOnnxEngine implements VoiceEngine {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final MobileSpeechToTextEngine _fallbackEngine = MobileSpeechToTextEngine();

  sherpa.OfflineRecognizer? _recognizer;
  bool _isSherpaInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  String? _lastErrorMessage;
  String? _tempRecordingPath;
  bool _usingFallback = false;

  VoidCallback? _activeStoppedCallback;
  Function(String recognizedWords, bool isFinal)? _activeResultCallback;

  @override
  String get engineName => _usingFallback
      ? 'Desktop Fallback Engine (${_fallbackEngine.engineName})'
      : 'Sherpa-ONNX 1.13.8 (Offline Desktop Engine)';

  @override
  bool get isInitialized => _isSherpaInitialized || _fallbackEngine.isInitialized;

  @override
  bool get isListening => _isListening || _fallbackEngine.isListening;

  @override
  bool get isAvailable => _isSherpaInitialized || _fallbackEngine.isAvailable;

  @override
  String get lastWords => _usingFallback ? _fallbackEngine.lastWords : _lastWords;

  @override
  String? get lastErrorMessage => _lastErrorMessage ?? (_usingFallback ? _fallbackEngine.lastErrorMessage : null);

  @override
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(String error)? onError,
  }) async {
    _lastErrorMessage = null;
    _usingFallback = false;

    try {
      // 1. Locate the native DLL directory for Windows
      final exeDir = p.dirname(Platform.resolvedExecutable);
      debugPrint('Initializing Sherpa-ONNX bindings from executable dir: $exeDir');

      try {
        if (Platform.isWindows) {
          final onnxDll = p.join(exeDir, 'onnxruntime.dll');
          if (File(onnxDll).existsSync()) {
            DynamicLibrary.open(onnxDll);
          }
        }
        sherpa.initBindings(exeDir);
      } catch (e) {
        debugPrint('Note loading bindings with exeDir: $e, trying default initBindingsAsync...');
        await sherpa.initBindingsAsync();
      }

      // 2. Discover local offline model directory
      final modelDir = await _findModelDirectory(exeDir);
      if (modelDir != null) {
        _initRecognizerWithModel(modelDir);
        _isSherpaInitialized = _recognizer != null;
        if (_isSherpaInitialized) {
          debugPrint('Sherpa-ONNX offline recognizer initialized successfully with model at: $modelDir');
          onStatus?.call('ready');
          return true;
        }
      }

      debugPrint('No Sherpa-ONNX offline model files found in models directory.');
      _lastErrorMessage = 'Offline model not found. Initializing fallback speech engine...';
    } catch (e) {
      debugPrint('Sherpa-ONNX init exception: $e');
      _lastErrorMessage = 'Sherpa-ONNX initialization: $e';
    }

    // 3. Fallback to platform native speech engine if offline model is not yet placed
    debugPrint('Engaging fallback speech engine for desktop...');
    _usingFallback = true;
    final fallbackOk = await _fallbackEngine.initialize(onStatus: onStatus, onError: onError);
    if (!fallbackOk && _lastErrorMessage == null) {
      _lastErrorMessage = _fallbackEngine.lastErrorMessage;
    }
    return fallbackOk;
  }

  void _initRecognizerWithModel(String modelDir) {
    try {
      // Check for Whisper model (encoder.onnx, decoder.onnx, tokens.txt)
      final whisperEncoder = p.join(modelDir, 'tiny.en-encoder.onnx');
      final whisperDecoder = p.join(modelDir, 'tiny.en-decoder.onnx');
      final whisperTokens = p.join(modelDir, 'tiny.en-tokens.txt');

      if (File(whisperEncoder).existsSync() &&
          File(whisperDecoder).existsSync() &&
          File(whisperTokens).existsSync()) {
        final config = sherpa.OfflineRecognizerConfig(
          model: sherpa.OfflineModelConfig(
            whisper: sherpa.OfflineWhisperModelConfig(
              encoder: whisperEncoder,
              decoder: whisperDecoder,
            ),
            tokens: whisperTokens,
            numThreads: 2,
            debug: false,
          ),
        );
        _recognizer = sherpa.OfflineRecognizer(config);
        return;
      }

      // Check for SenseVoice model (model.onnx, tokens.txt)
      final senseModel = p.join(modelDir, 'model.int8.onnx');
      final senseTokens = p.join(modelDir, 'tokens.txt');
      final targetSense = File(senseModel).existsSync() ? senseModel : p.join(modelDir, 'model.onnx');

      if (File(targetSense).existsSync() && File(senseTokens).existsSync()) {
        final config = sherpa.OfflineRecognizerConfig(
          model: sherpa.OfflineModelConfig(
            senseVoice: sherpa.OfflineSenseVoiceModelConfig(
              model: targetSense,
              language: 'en',
              useInverseTextNormalization: true,
            ),
            tokens: senseTokens,
            numThreads: 2,
            debug: false,
          ),
        );
        _recognizer = sherpa.OfflineRecognizer(config);
        return;
      }
    } catch (e) {
      debugPrint('Error configuring Sherpa-ONNX model: $e');
      _recognizer = null;
    }
  }

  Future<String?> _findModelDirectory(String exeDir) async {
    final candidatePaths = [
      p.join(exeDir, 'models'),
      p.join(exeDir, 'data', 'models'),
      p.join(Directory.current.path, 'models'),
    ];

    try {
      final appSupport = await getApplicationSupportDirectory();
      candidatePaths.add(p.join(appSupport.path, 'models'));
    } catch (_) {}

    for (final dirPath in candidatePaths) {
      final dir = Directory(dirPath);
      if (dir.existsSync()) {
        final files = dir.listSync();
        if (files.any((f) => f.path.endsWith('.onnx'))) {
          return dirPath;
        }
      }
    }
    return null;
  }

  @override
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    VoidCallback? onStarted,
    VoidCallback? onStopped,
    String? localeId,
  }) async {
    _lastErrorMessage = null;
    _activeStoppedCallback = onStopped;
    _activeResultCallback = onResult;

    if (_usingFallback || !_isSherpaInitialized || _recognizer == null) {
      _usingFallback = true;
      return _fallbackEngine.startListening(
        onResult: onResult,
        onStarted: onStarted,
        onStopped: onStopped,
        localeId: localeId,
      );
    }

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _lastErrorMessage = 'Microphone permission was denied on this system.';
        return false;
      }

      final tempDir = await getTemporaryDirectory();
      _tempRecordingPath = p.join(tempDir.path, 'voice_input_${DateTime.now().millisecondsSinceEpoch}.wav');

      _lastWords = '';
      _isListening = true;
      onStarted?.call();

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _tempRecordingPath!,
      );

      return true;
    } catch (e) {
      debugPrint('Failed to start desktop recording: $e');
      _lastErrorMessage = 'Desktop recording error: $e';
      _isListening = false;
      onStopped?.call();
      return false;
    }
  }

  @override
  Future<void> stopListening() async {
    if (_usingFallback) {
      await _fallbackEngine.stopListening();
      return;
    }

    if (!_isListening) return;
    _isListening = false;

    try {
      final path = await _audioRecorder.stop();
      final audioPath = path ?? _tempRecordingPath;

      if (audioPath != null && File(audioPath).existsSync() && _recognizer != null) {
        final waveData = sherpa.readWave(audioPath);
        if (waveData.samples.isNotEmpty) {
          final stream = _recognizer!.createStream();
          stream.acceptWaveform(
            sampleRate: waveData.sampleRate,
            samples: waveData.samples,
          );
          _recognizer!.decode(stream);
          final result = _recognizer!.getResult(stream);
          final text = result.text.trim();

          _lastWords = text;
          _activeResultCallback?.call(text, true);
        }

        // Clean up temporary audio file
        try {
          File(audioPath).deleteSync();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('Error decoding desktop audio with Sherpa-ONNX: $e');
      _lastErrorMessage = 'Decode error: $e';
    } finally {
      _activeStoppedCallback?.call();
    }
  }

  @override
  Future<void> cancelListening() async {
    if (_usingFallback) {
      await _fallbackEngine.cancelListening();
      return;
    }

    _isListening = false;
    try {
      await _audioRecorder.stop();
      if (_tempRecordingPath != null && File(_tempRecordingPath!).existsSync()) {
        File(_tempRecordingPath!).deleteSync();
      }
    } catch (_) {}
    _activeStoppedCallback?.call();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _fallbackEngine.dispose();
  }
}
