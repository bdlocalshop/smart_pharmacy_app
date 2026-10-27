import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../services/voice_input_service.dart';

/// Reusable voice input button designed to be embedded as a `suffixIcon` in any
/// `TextField` or `TextFormField` (such as POS search bar, medicine forms, customer fields).
/// Supports continuous speech-to-text, real-time typing preview, and animated listening feedback.
class VoiceInputSuffixIcon extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final double iconSize;
  final String tooltip;
  final bool appendMode;

  const VoiceInputSuffixIcon({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.iconSize = 20.0,
    this.tooltip = 'Voice Search & Input',
    this.appendMode = false,
  });

  @override
  ConsumerState<VoiceInputSuffixIcon> createState() => _VoiceInputSuffixIconState();
}

class _VoiceInputSuffixIconState extends ConsumerState<VoiceInputSuffixIcon>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _initialPrefix = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    final voiceService = ref.read(voiceInputServiceProvider);

    if (_isListening) {
      await voiceService.stopListening();
      if (mounted) {
        setState(() => _isListening = false);
        _pulseController.stop();
        _pulseController.reset();
        widget.onSubmitted?.call();
      }
      return;
    }

    _initialPrefix = widget.appendMode && widget.controller.text.isNotEmpty
        ? '${widget.controller.text.trim()} '
        : '';

    final started = await voiceService.startListening(
      onStarted: () {
        if (mounted) {
          setState(() => _isListening = true);
          _pulseController.repeat(reverse: true);
        }
      },
      onStopped: () {
        if (mounted) {
          setState(() => _isListening = false);
          _pulseController.stop();
          _pulseController.reset();
          widget.onSubmitted?.call();
        }
      },
      onResult: (recognizedWords, isFinal) {
        if (!mounted) return;
        final updatedText = '$_initialPrefix$recognizedWords';
        widget.controller.text = updatedText;
        widget.controller.selection = TextSelection.collapsed(offset: updatedText.length);
        widget.onChanged?.call(updatedText);

        if (isFinal) {
          setState(() => _isListening = false);
          _pulseController.stop();
          _pulseController.reset();
          widget.onSubmitted?.call();
        }
      },
    );

    if (!started && mounted) {
      setState(() => _isListening = false);
      _pulseController.stop();
      _pulseController.reset();

      final failureMsg = voiceService.lastErrorMessage ??
          'Voice input is unavailable or microphone permission was denied.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mic_off, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  failureMsg,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.alertCritical,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _isListening ? 'Listening... Tap to finish' : widget.tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _toggleListening,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isListening ? _pulseAnimation.value : 1.0,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none_outlined,
                  size: widget.iconSize,
                  color: _isListening ? AppColors.alertCritical : AppColors.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
