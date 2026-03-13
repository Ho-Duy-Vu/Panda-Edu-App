import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Speech error: $error'),
        onStatus: (status) => print('Speech status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('Error initializing speech: $e');
      return false;
    }
  }

  bool get isAvailable => _isInitialized && _speech.isAvailable;

  Future<void> startListening({
    required Function(String) onResult,
    String localeId = 'vi_VN',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isInitialized) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    }
  }

  Future<void> stopListening() async {
    if (_isInitialized) {
      await _speech.stop();
    }
  }

  Future<void> cancelListening() async {
    if (_isInitialized) {
      await _speech.cancel();
    }
  }

  bool get isListening => _speech.isListening;

  Future<List<stt.LocaleName>> get locales async => await _speech.locales();

  String? get lastError => _speech.lastError?.errorMsg;
}
