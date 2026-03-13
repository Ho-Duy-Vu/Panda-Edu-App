import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔊 [TTS] Initializing TTS Service...');
      
      // Kiểm tra các ngôn ngữ có sẵn
      try {
        final languages = await _flutterTts.getLanguages;
        print('🔊 [TTS] Available languages: $languages');
      } catch (e) {
        print('⚠️ [TTS] Could not get available languages: $e');
      }

      // Thử set tiếng Việt, nếu không có thì dùng tiếng Anh
      try {
        await _flutterTts.setLanguage("vi-VN");
        print('🔊 [TTS] Language set to: vi-VN');
      } catch (e) {
        print('⚠️ [TTS] Vietnamese not available, falling back to en-US');
        await _flutterTts.setLanguage("en-US");
      }

      // Cải thiện giọng nói: tốc độ chậm hơn, giọng nữ tự nhiên hơn
      await _flutterTts.setSpeechRate(0.45); // Tốc độ chậm hơn để rõ hơn (0.0 - 1.0)
      await _flutterTts.setVolume(1.0); // Âm lượng tối đa
      await _flutterTts.setPitch(1.1); // Giọng nữ tự nhiên hơn (0.5 - 2.0)
      
      // Cố gắng chọn giọng tốt nhất
      try {
        final voices = await _flutterTts.getVoices;
        if (voices != null && voices.isNotEmpty) {
          // Ưu tiên giọng tiếng Việt chất lượng cao
          final vnVoices = voices.where((voice) => 
            voice['locale']?.toString().contains('vi') == true
          ).toList();
          
          if (vnVoices.isNotEmpty) {
            // Chọn giọng nữ nếu có
            final femaleVoice = vnVoices.firstWhere(
              (v) => v['name']?.toString().toLowerCase().contains('female') == true ||
                     v['name']?.toString().toLowerCase().contains('nữ') == true,
              orElse: () => vnVoices.first,
            );
            await _flutterTts.setVoice({
              "name": femaleVoice['name'],
              "locale": femaleVoice['locale']
            });
            print('🔊 [TTS] Selected voice: ${femaleVoice['name']}');
          } else {
            // Nếu không có tiếng Việt, chọn giọng Anh chất lượng cao
            final enVoices = voices.where((voice) => 
              voice['locale']?.toString().contains('en') == true
            ).toList();
            
            if (enVoices.isNotEmpty) {
              final goodVoice = enVoices.firstWhere(
                (v) => v['name']?.toString().toLowerCase().contains('enhanced') == true ||
                       v['name']?.toString().toLowerCase().contains('premium') == true,
                orElse: () => enVoices.first,
              );
              await _flutterTts.setVoice({
                "name": goodVoice['name'],
                "locale": goodVoice['locale']
              });
              print('🔊 [TTS] Selected English voice: ${goodVoice['name']}');
            }
          }
        }
      } catch (e) {
        print('⚠️ [TTS] Could not set specific voice: $e');
      }

      print('🔊 [TTS] Settings: rate=0.45, volume=1.0, pitch=1.1');

      // Callback khi bắt đầu
      _flutterTts.setStartHandler(() {
        print('🔊 [TTS] Started speaking');
        _isSpeaking = true;
      });

      // Callback khi hoàn thành
      _flutterTts.setCompletionHandler(() {
        print('🔊 [TTS] Completed speaking');
        _isSpeaking = false;
      });

      // Callback khi bị cancel
      _flutterTts.setCancelHandler(() {
        print('🔊 [TTS] Cancelled');
        _isSpeaking = false;
      });

      // Callback khi có lỗi
      _flutterTts.setErrorHandler((msg) {
        print('❌ [TTS] Error: $msg');
        _isSpeaking = false;
      });

      _isInitialized = true;
      print('✅ [TTS] TTS Service initialized successfully');
    } catch (e) {
      print('❌ [TTS] Failed to initialize: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Phát hiện ngôn ngữ của text
  String _detectLanguage(String text) {
    // Đếm ký tự tiếng Việt (có dấu)
    final vietnameseChars = RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ]');
    final vietnameseCount = vietnameseChars.allMatches(text).length;
    
    // Nếu có ít nhất 30% ký tự có dấu tiếng Việt → tiếng Việt
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;
    if (totalChars > 0 && vietnameseCount / totalChars > 0.3) {
      return 'vi-VN';
    }
    
    // Nếu toàn bộ là Latin không dấu → tiếng Anh
    final latinOnly = RegExp(r'^[a-zA-Z0-9\s\.,!?\-]+$');
    if (latinOnly.hasMatch(text.trim())) {
      return 'en-US';
    }
    
    // Mặc định tiếng Việt
    return 'vi-VN';
  }

  /// Đọc text
  Future<bool> speak(String text) async {
    if (!_isInitialized) {
      print('⚠️ [TTS] Not initialized, initializing now...');
      try {
        await initialize();
      } catch (e) {
        print('❌ [TTS] Failed to initialize: $e');
        return false;
      }
    }

    if (text.isEmpty) {
      print('⚠️ [TTS] Empty text, skipping');
      return false;
    }

    try {
      // Phát hiện ngôn ngữ và đổi language setting
      final detectedLang = _detectLanguage(text);
      await _flutterTts.setLanguage(detectedLang);
      print('🔊 [TTS] Detected language: $detectedLang');
      
      print('🔊 [TTS] Speaking: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');
      final result = await _flutterTts.speak(text);
      
      if (result == 1) {
        print('✅ [TTS] Speak command successful');
        return true;
      } else {
        print('⚠️ [TTS] Speak command returned: $result');
        return false;
      }
    } catch (e) {
      print('❌ [TTS] Error speaking: $e');
      _isSpeaking = false;
      return false;
    }
  }

  /// Dừng đọc
  Future<void> stop() async {
    try {
      print('🔊 [TTS] Stopping...');
      await _flutterTts.stop();
      _isSpeaking = false;
      print('✅ [TTS] Stopped');
    } catch (e) {
      print('❌ [TTS] Error stopping: $e');
    }
  }

  /// Tạm dừng đọc (chỉ trên một số nền tảng)
  Future<void> pause() async {
    try {
      print('🔊 [TTS] Pausing...');
      await _flutterTts.pause();
      print('✅ [TTS] Paused');
    } catch (e) {
      print('❌ [TTS] Error pausing: $e');
    }
  }

  /// Thay đổi tốc độ đọc
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      // Xử lý lỗi
    }
  }

  /// Thay đổi ngôn ngữ
  Future<void> setLanguage(String language) async {
    try {
      await _flutterTts.setLanguage(language);
    } catch (e) {
      // Xử lý lỗi
    }
  }

  /// Hủy service
  void dispose() {
    print('🔊 [TTS] Disposing TTS Service');
    _flutterTts.stop();
  }
}

