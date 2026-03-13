import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/record_stt_provider.dart';
import '../widgets/live_transcript_view.dart';
import '../../core/constants.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _durationTimer;
  int _elapsedSeconds = 0;
  String? _collectionId; // Lưu collection được select khi user tap record từ folder

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    // Nhận collectionId nếu user tap record từ folder cụ thể
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('collectionId')) {
        _collectionId = args['collectionId'];
      }
      
      // Initialize STT
      context.read<RecordSttProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _durationTimer?.cancel();
    super.dispose();
  }

  void _startDurationTimer() {
    _elapsedSeconds = 0;
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        context.read<RecordSttProvider>().updateDuration(_elapsedSeconds);
      });

      // Auto-stop at max duration
      if (_elapsedSeconds >= FlashcardValidator.maxRecordingDurationSeconds) {
        _stopListening();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đạt thời gian tối đa!')),
        );
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
  }

  Future<void> _startListening() async {
    final provider = context.read<RecordSttProvider>();
    
    // Reset error trước khi bắt đầu
    provider.reset();
    
    final success = await provider.startListening();
    
    if (!mounted) return;
    
    if (success) {
      _startDurationTimer();
    } else {
      // Hiển thị lỗi chi tiết
      final errorMsg = provider.errorMessage ?? 'Không thể bắt đầu nhận diện giọng nói';
      
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('❌ Lỗi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(errorMsg),
              const SizedBox(height: 16),
              const Text(
                'Các giải pháp:\n'
                '• Kiểm tra quyền microphone\n'
                '• Thử khởi động lại app\n'
                '• Hoặc nhập thủ công sau',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Thử lại'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamed(
                  context,
                  '/confirm-transcript',
                  arguments: {
                    'audioPath': null,
                    'transcript': '',
                    'duration': 0,
                  },
                );
              },
              child: const Text('Nhập thủ công'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _stopListening() async {
    _stopDurationTimer();
    
    final provider = context.read<RecordSttProvider>();
    await provider.stopListening();

    // Kiểm tra thời gian tối thiểu
    if (_elapsedSeconds < FlashcardValidator.minRecordingDurationSeconds) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ghi âm quá ngắn (tối thiểu 1 giây)'),
          duration: Duration(seconds: 2),
        ),
      );
      provider.reset();
      return;
    }

    // Nếu không có transcript, cho phép nhập thủ công
    if (provider.transcript.isEmpty) {
      if (!mounted) return;
      
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Không nhận diện được giọng nói'),
          content: const Text(
            'Không có văn bản nào được nhận diện.\n\n'
            'Bạn có muốn tạo flashcard và nhập nội dung thủ công không?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      );

      if (shouldContinue != true) {
        provider.reset();
        return;
      }
    }

    // Chuyển sang confirm page
    if (!mounted) return;
    
    Navigator.pushNamed(
      context,
      '/confirm-transcript',
      arguments: {
        'audioPath': null, // Không lưu audio
        'transcript': provider.transcript.isNotEmpty 
            ? provider.transcript 
            : '', // Empty nếu không có
        'duration': _elapsedSeconds,
        'collectionId': _collectionId, // Pass collection nếu user record từ folder cụ thể
      },
    ).then((_) {
      provider.reset();
    });
  }

  Future<void> _cancelListening() async {
    _stopDurationTimer();
    await context.read<RecordSttProvider>().cancelListening();
    Navigator.pop(context);
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhận diện giọng nói'),
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            final provider = context.read<RecordSttProvider>();
            if (provider.state == RecordingState.listening) {
              _cancelListening();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Consumer<RecordSttProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                children: [
                  // Panda animation
                  SizedBox(
                    height: 220,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: provider.state == RecordingState.listening
                                    ? 1.0 + (_pulseController.value * 0.1)
                                    : 1.0,
                                child: Image.asset(
                                  'assets/images/panda_mic.webp',
                                  width: 120,
                                  height: 120,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          Text(
                            _formatDuration(_elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppColors.matchaMedium,
                            ),
                          ),
                          if (provider.state == RecordingState.listening) ...[
                            const SizedBox(height: AppSizes.paddingSmall),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Đang lắng nghe...',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          // Progress bar
                          const SizedBox(height: AppSizes.paddingLarge),
                          LinearProgressIndicator(
                            value: _elapsedSeconds /
                                FlashcardValidator.maxRecordingDurationSeconds,
                            backgroundColor: AppColors.matchaLight,
                            valueColor: AlwaysStoppedAnimation(
                              _elapsedSeconds >=
                                      FlashcardValidator.maxRecordingDurationSeconds * 0.9
                                  ? AppColors.error
                                  : AppColors.matchaMedium,
                            ),
                          ),
                          ],
                        ),
                      ),
                    ),

                  // Live Transcript
                  if (provider.isSttAvailable)
                    Container(
                      height: 160, // Giảm từ 180 xuống 160
                      margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
                      child: LiveTranscriptView(
                        transcript: provider.transcript,
                        isListening: provider.state == RecordingState.listening,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingMedium),
                      margin: const EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange),
                              SizedBox(width: AppSizes.paddingSmall),
                              Expanded(
                                child: Text(
                                  'Nhận dạng giọng nói không khả dụng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.paddingSmall),
                          const Text(
                            'Bạn vẫn có thể tạo flashcard bằng cách nhập thủ công sau.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: AppSizes.paddingMedium),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/confirm-transcript',
                                arguments: {
                                  'audioPath': null,
                                  'transcript': '',
                                  'duration': 0,
                                },
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Tạo flashcard thủ công'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.matchaMedium,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Control Buttons
                  const SizedBox(height: AppSizes.paddingMedium),
                  if (provider.state == RecordingState.idle ||
                      provider.state == RecordingState.error)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingLarge),
                      child: SizedBox(
                        width: 160,
                        height: 160,
                        child: FloatingActionButton(
                          onPressed: _startListening,
                          backgroundColor: AppColors.accentOrange,
                          child: const Icon(
                            Icons.mic,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else if (provider.state == RecordingState.listening)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.paddingLarge),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        FloatingActionButton(
                          onPressed: _cancelListening,
                          backgroundColor: Colors.grey,
                          child: const Icon(Icons.close),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: FloatingActionButton(
                            onPressed: _stopListening,
                            backgroundColor: AppColors.error,
                            child: const Icon(
                              Icons.stop,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
