import 'package:flutter/material.dart';
import '../../core/services/speech_service.dart';
import '../../core/services/permissions_service.dart';

enum RecordingState {
  idle,
  listening,
  stopped,
  error,
}

class RecordSttProvider extends ChangeNotifier {
  final SpeechService speechService;
  final PermissionsService permissionsService;

  RecordingState _state = RecordingState.idle;
  String _transcript = '';
  int _duration = 0;
  String? _errorMessage;
  bool _isSttAvailable = false;

  RecordSttProvider({
    required this.speechService,
    required this.permissionsService,
  });

  RecordingState get state => _state;
  String get transcript => _transcript;
  int get duration => _duration;
  String? get errorMessage => _errorMessage;
  bool get isSttAvailable => _isSttAvailable;

  Future<void> initialize() async {
    try {
      _isSttAvailable = await speechService.initialize();
      notifyListeners();
    } catch (e) {
      _isSttAvailable = false;
      notifyListeners();
    }
  }

  Future<bool> startListening() async {
    try {
      // Check permissions
      final hasPermission = await permissionsService.checkMicrophonePermission();
      if (!hasPermission) {
        final granted = await permissionsService.requestMicrophonePermission();
        if (!granted) {
          _state = RecordingState.error;
          _errorMessage = 'Cần quyền truy cập microphone để nhận diện giọng nói';
          notifyListeners();
          return false;
        }
      }

      if (!_isSttAvailable) {
        _state = RecordingState.error;
        _errorMessage = 'Speech-to-Text không khả dụng';
        notifyListeners();
        return false;
      }

      _state = RecordingState.listening;
      _transcript = '';
      _duration = 0;
      _errorMessage = null;
      notifyListeners();

      // Start STT
      await speechService.startListening(
        onResult: (text) {
          _transcript = text;
          notifyListeners();
        },
        localeId: 'vi_VN',
      );

      return true;
    } catch (e) {
      _state = RecordingState.error;
      _errorMessage = 'Lỗi: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      // Stop STT
      if (_isSttAvailable) {
        await speechService.stopListening();
      }

      _state = RecordingState.stopped;
      notifyListeners();
    } catch (e) {
      _state = RecordingState.error;
      _errorMessage = 'Lỗi khi dừng nhận diện: $e';
      notifyListeners();
    }
  }

  Future<void> cancelListening() async {
    try {
      if (_isSttAvailable) {
        await speechService.cancelListening();
      }

      _state = RecordingState.idle;
      _transcript = '';
      _duration = 0;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('Error canceling listening: $e');
    }
  }

  void updateDuration(int seconds) {
    _duration = seconds;
    notifyListeners();
  }

  void reset() {
    _state = RecordingState.idle;
    _transcript = '';
    _duration = 0;
    _errorMessage = null;
    notifyListeners();
  }
}

