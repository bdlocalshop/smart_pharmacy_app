import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:smart_pharmacy_app/core/services/voice_input_service.dart';
import 'package:smart_pharmacy_app/core/widgets/voice_input_suffix_icon.dart';

class MockVoiceInputService extends VoiceInputService {
  bool mockAvailable = true;
  bool isMockListening = false;
  Function(String, bool)? activeCallback;
  VoidCallback? activeStopped;

  @override
  bool get isAvailable => mockAvailable;

  @override
  bool get isListening => isMockListening;

  @override
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(SpeechRecognitionError error)? onError,
  }) async {
    return mockAvailable;
  }

  @override
  Future<bool> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    VoidCallback? onStarted,
    VoidCallback? onStopped,
    String? localeId,
  }) async {
    if (!mockAvailable) return false;
    isMockListening = true;
    activeCallback = onResult;
    activeStopped = onStopped;
    onStarted?.call();
    return true;
  }

  @override
  Future<void> stopListening() async {
    isMockListening = false;
    activeStopped?.call();
  }

  @override
  Future<void> cancelListening() async {
    isMockListening = false;
    activeStopped?.call();
  }

  void simulateSpeech(String words, {bool isFinal = false}) {
    if (isFinal) {
      isMockListening = false;
      activeStopped?.call();
    }
    activeCallback?.call(words, isFinal);
  }
}

void main() {
  group('VoiceInputSuffixIcon & Voice Service Tests', () {
    testWidgets('Renders microphone icon with proper tooltip', (tester) async {
      final controller = TextEditingController();
      final mockVoiceService = MockVoiceInputService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceInputServiceProvider.overrideWithValue(mockVoiceService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VoiceInputSuffixIcon(
                controller: controller,
                tooltip: 'Voice Search Medicine',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_none_outlined), findsOneWidget);
      expect(find.byTooltip('Voice Search Medicine'), findsOneWidget);
    });

    testWidgets('Tapping microphone initiates voice listening and populates controller in real time', (tester) async {
      final controller = TextEditingController();
      String lastChanged = '';
      final mockVoiceService = MockVoiceInputService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceInputServiceProvider.overrideWithValue(mockVoiceService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VoiceInputSuffixIcon(
                controller: controller,
                onChanged: (val) => lastChanged = val,
              ),
            ),
          ),
        ),
      );

      // Tap microphone to start listening
      await tester.tap(find.byType(VoiceInputSuffixIcon));
      await tester.pump();

      expect(mockVoiceService.isMockListening, isTrue);
      expect(find.byIcon(Icons.mic), findsOneWidget);

      // Simulate voice input result "Paracetamol 500mg"
      mockVoiceService.simulateSpeech('Paracetamol 500mg', isFinal: false);
      await tester.pump();

      expect(controller.text, equals('Paracetamol 500mg'));
      expect(lastChanged, equals('Paracetamol 500mg'));

      // Finalize speech
      mockVoiceService.simulateSpeech('Paracetamol 500mg', isFinal: true);
      await tester.pumpAndSettle();

      expect(mockVoiceService.isMockListening, isFalse);
      expect(find.byIcon(Icons.mic_none_outlined), findsOneWidget);
    });

    testWidgets('Displays fallback feedback if speech recognition is unavailable on device', (tester) async {
      final controller = TextEditingController();
      final mockVoiceService = MockVoiceInputService()..mockAvailable = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            voiceInputServiceProvider.overrideWithValue(mockVoiceService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VoiceInputSuffixIcon(
                controller: controller,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(VoiceInputSuffixIcon));
      await tester.pumpAndSettle();

      expect(find.text('Voice input is unavailable or microphone permission was denied.'), findsOneWidget);
    });
  });
}
