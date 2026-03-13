import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/flip_card_widget.dart';
import '../widgets/panda_empty_state.dart';
import '../../domain/entities/flashcard.dart';
import '../../core/constants.dart';
import '../../services/tts_service.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  final TtsService _ttsService = TtsService();
  bool _isSpeaking = false;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _ttsService.initialize();
    // Load collections và cards ngay khi init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().loadCollections();
      _loadCards(); // Load cards luôn
    });
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final provider = context.read<FlashcardProvider>();
      
      // Optimization: Dùng flashcards đã load sẵn thay vì await getDueFlashcards()
      List<Flashcard> allCards = provider.flashcards.isNotEmpty 
          ? provider.flashcards 
          : await provider.getDueFlashcards();
      
      if (!mounted) return;
      
      // Filter cards by selected collection
      List<Flashcard> filteredCards = allCards;
      if (_selectedCollectionId != null) {
        if (_selectedCollectionId == 'uncategorized') {
          filteredCards = allCards.where((c) => c.collectionId == null).toList();
        } else {
          filteredCards = allCards.where((c) => c.collectionId == _selectedCollectionId).toList();
        }
      }
      
      setState(() {
        _cards = filteredCards;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Không thể tải flashcards. Vui lòng thử lại.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _toggleSpeak() async {
    if (_cards.isEmpty) return;
    
    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final success = await _ttsService.speak(_cards[_currentIndex].transcript);
      
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
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_ttsService.isSpeaking) {
            setState(() => _isSpeaking = false);
          }
        });
      }
    }
  }

  void _nextCard() {
    // Dừng đọc khi chuyển card
    if (_isSpeaking) {
      _ttsService.stop();
      setState(() => _isSpeaking = false);
    }
    
    if (_currentIndex < _cards.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    // Dừng đọc khi chuyển card
    if (_isSpeaking) {
      _ttsService.stop();
      setState(() => _isSpeaking = false);
    }
    
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Hoàn thành!'),
        content: Text('Bạn đã xem hết ${_cards.length} flashcard!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Về trang chủ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
            child: const Text('Học lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ôn tập Flashcards'),
            Text(
              'by VUHO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          if (_cards.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: () {
                setState(() => _currentIndex = 0);
              },
              tooltip: 'Bắt đầu lại',
            ),
        ],
      ),
      body: Column(
        children: [
          // Collection selector
          Consumer<CollectionProvider>(
            builder: (context, collectionProvider, _) {
              return Container(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                color: AppColors.milkWhite,
                child: DropdownButtonFormField<String?>(
                  decoration: InputDecoration(
                    labelText: 'Chọn thư mục để ôn tập',
                    prefixIcon: const Icon(Icons.folder),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                  ),
                  value: _selectedCollectionId,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tất cả flashcard'),
                    ),
                    const DropdownMenuItem(
                      value: 'uncategorized',
                      child: Text('Chưa phân loại'),
                    ),
                    ...collectionProvider.collections
                        .map((collection) => DropdownMenuItem(
                              value: collection.id,
                              child: Text(collection.name),
                            ))
                        .toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCollectionId = value;
                      _loadCards();
                    });
                  },
                ),
              );
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_errorMessage!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadCards,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _cards.isEmpty
                        ? const PandaEmptyState(
                            message: 'Chưa có flashcard nào trong thư mục này!\nHãy tạo hoặc chọn thư mục khác',
                          )
                        : _buildFlipCardView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCardView() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Progress
          Text(
            '${_currentIndex + 1} / ${_cards.length}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _cards.length,
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Flip Card
          Expanded(
            child: FlipCardWidget(
              front: _cards[_currentIndex].title,
              back: _cards[_currentIndex].transcript,
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Nút đọc nội dung
          ElevatedButton.icon(
            onPressed: _toggleSpeak,
            icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
            label: Text(_isSpeaking ? 'Dừng đọc' : 'Đọc nội dung'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSpeaking ? AppColors.error : AppColors.matchaMedium,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLarge),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _currentIndex > 0 ? _previousCard : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.matchaMedium,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _nextCard,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  _currentIndex < _cards.length - 1 ? 'Tiếp theo' : 'Hoàn thành',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.matchaDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
