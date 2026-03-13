import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../../domain/entities/flashcard.dart';
import '../../core/constants.dart';
import '../../services/tts_service.dart';

class DetailPage extends StatefulWidget {
  final Flashcard flashcard;

  const DetailPage({super.key, required this.flashcard});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Flashcard _currentFlashcard;
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _currentFlashcard = widget.flashcard;
    _ttsService.initialize();
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _toggleSpeak() async {
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final success = await _ttsService.speak(_currentFlashcard.transcript);
      
      if (!success && mounted) {
        // Nếu TTS thất bại, hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể đọc nội dung. Vui lòng kiểm tra cài đặt TTS của thiết bị.'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _isSpeaking = false);
      } else {
        // Sau khi đọc xong (callback sẽ set _isSpeaking = false)
        // Nhưng để đảm bảo UI sync, ta check sau 100ms
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_ttsService.isSpeaking) {
            setState(() => _isSpeaking = false);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết'),
        actions: [
          IconButton(
            icon: Icon(
              _currentFlashcard.favorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () async {
              final provider = context.read<FlashcardProvider>();
              await provider.toggleFavorite(_currentFlashcard);
              
              // Refresh data
              if (!mounted) return;
              final updated = provider.flashcards.firstWhere(
                (c) => c.id == _currentFlashcard.id,
                orElse: () => _currentFlashcard,
              );
              setState(() {
                _currentFlashcard = updated;
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Chỉnh sửa'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Xóa', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'edit') {
                // Navigate to edit page
                final result = await Navigator.pushNamed(
                  context,
                  '/edit-flashcard',
                  arguments: _currentFlashcard,
                );
                
                // Reload data nếu edited
                if (result == true && mounted) {
                  final provider = context.read<FlashcardProvider>();
                  final updated = provider.flashcards.firstWhere(
                    (c) => c.id == _currentFlashcard.id,
                    orElse: () => _currentFlashcard,
                  );
                  setState(() {
                    _currentFlashcard = updated;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật flashcard')),
                  );
                }
              } else if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận'),
                    content: const Text('Xóa flashcard này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && mounted) {
                  final provider = context.read<FlashcardProvider>();
                  await provider.deleteFlashcard(_currentFlashcard.id);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa flashcard')),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panda Image
            Center(
              child: Image.asset(
                'assets/images/panda_placeholder.webp',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Title
            Text(
              _currentFlashcard.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Audio Player (only if audioPath exists)
            if (_currentFlashcard.audioPath != null && _currentFlashcard.audioPath!.isNotEmpty) ...[
              const Text(
                'Audio:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: AudioPlayerWidget(audioPath: _currentFlashcard.audioPath!),
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),
            ],

            // Transcript
            const Text(
              'Nội dung:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentFlashcard.transcript,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    // Nút đọc nội dung
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _toggleSpeak,
                        icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                        label: Text(_isSpeaking ? 'Dừng đọc' : 'Đọc nội dung'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSpeaking ? AppColors.error : AppColors.matchaMedium,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
