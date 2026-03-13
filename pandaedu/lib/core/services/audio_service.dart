// AudioService - Simplified for playback only
// Recording functionality removed - using speech_to_text for voice input
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playAudio(String path) async {
    try {
      await _player.play(DeviceFileSource(path));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> pauseAudio() async {
    await _player.pause();
  }

  Future<void> stopAudio() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

