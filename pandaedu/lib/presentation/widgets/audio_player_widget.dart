import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../core/constants.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final Color? iconColor;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.iconColor,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setSourceDeviceFile(widget.audioPath);

    _player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _player.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });

    _player.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(DeviceFileSource(widget.audioPath));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 40,
          ),
          color: widget.iconColor ?? AppColors.matchaMedium,
          onPressed: _playPause,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await _player.seek(position);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
